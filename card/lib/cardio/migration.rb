# -*- encoding : utf-8 -*-

module Cardio
  class Migration < ActiveRecord::Migration[6.1]
    include Card::Model::SaveHelper unless ENV["NO_CARD_LOAD"]

    class << self
      attr_reader :migration_type, :old_table, :old_deck_table

      def migration_class type
        type == :schema ? Migration::Schema : Migration::Transform
      end

      def new_for type
        migration_class(type).new
      end

      def port_all
        %i[schema transform].each do |type|
          new_for(type).port
        end
      end

      private

      def port
        return unless connection.table_exists? old_deck_table
        connection.rename_table old_table, table
        connection.execute "INSERT INTO #{table} SELECT * from #{old_deck_table}"
        connection.drop_table old_deck_table
      end

      def table
        "#{migration_type}_migrations"
      end

      def connection
        ActiveRecord::Base.connection
      end
    end

    delegate :connection, to: :class

    def migration_type
      self.class.migration_type || :schema
    end

    def assume_current
      context do |mc|
        versions = mc.migrations.map(&:version)
        migrated = mc.get_all_versions
        to_mark = versions - migrated
        mark_as_migrated to_mark if to_mark.present?
      end
    end

    def assume_migrated_upto_version version=nil
      mode do |_paths|
        version ||= self.version
        ActiveRecord::Schema.assume_migrated_upto_version version
      end
    end

    def run version=nil, verbose=true
      context do |mc|
        ActiveRecord::Migration.verbose = verbose
        mc.migrate version
      end
    end

    def version
      path = stamp_path
      File.exist?(path) ? File.read(path).strip : nil
    end

    def stamp
      mode do
        return unless (version = ActiveRecord::Migrator.current_version).to_i.positive?
        path = stamp_path
        return unless (file = ::File.open path, "w")

        puts ">>  writing version: #{version} to #{path}"
        file.puts version
      end
    end

    def migration_paths
      Cardio.paths["data/#{migration_type}"].existent.to_a
    end

    def context
      mode do |paths|
        yield ActiveRecord::MigrationContext.new(paths, ActiveRecord::SchemaMigration)
      end
    end

    def mode
      with_migration_table { yield migration_paths }
    # rescue
    #   binding.pry
    end

    def down
      raise ActiveRecord::IrreversibleMigration
    end

    private

    def stamp_path
      stamp_dir = ENV["SCHEMA_STAMP_PATH"] || File.join(Cardio.root, "db")

      File.join stamp_dir, "version_#{migration_type}.txt"
    end

    def with_migration_table
      yield
    end

    def table_name= table_name
      ActiveRecord::Base.schema_migrations_table_name = table_name
      ActiveRecord::SchemaMigration.table_name = table_name
      ActiveRecord::SchemaMigration.reset_column_information
    end

    def mark_as_migrated versions
      sql = connection.send :insert_versions_sql, versions
      connection.execute sql
    end
  end
end

