# -*- encoding : utf-8 -*-

module Cardio
  class Migration < ActiveRecord::Migration[6.1]
    include Card::Model::SaveHelper unless ENV["NO_CARD_LOAD"]

    class << self
      attr_reader :migration_type

      def migration_class type
        if type == :schema
          Migration::Schema
        else
          Migration::Transform
        end
      end

      def new_for type
        migration_class(type).new
      end
    end

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

    def migrate version=nil, verbose=true
      context do |mc|
        ActiveRecord::Migration.verbose = verbose
        mc.migrate version
      end
    end

    def version
      path = stamp_path
      File.exist?(path) ? File.read(path).strip : nil
    end

    def stamp_path
      stamp_dir = ENV["SCHEMA_STAMP_PATH"] || File.join(Cardio.root, "db")

      File.join stamp_dir, "version_#{migration_type}.txt"
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

    def connection
      ActiveRecord::Base.connection
    end
  end
end

