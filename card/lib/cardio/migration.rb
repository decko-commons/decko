# -*- encoding : utf-8 -*-

module Cardio
  class Migration < ActiveRecord::Migration[6.1]
    include Assumption
    include Stamp

    class << self
      attr_reader :migration_type, :old_tables, :old_deck_table

      def migration_class type
        type == :schema ? Migration::Schema : Migration::Transform
      end

      def new_for type
        migration_class(type).new
      end

      def port_all
        %i[schema transform].each do |type|
          migration_class(type).port
        end
      end

      def port
        return unless connection.table_exists? old_deck_table
        rename_old_tables
        connection.execute "INSERT INTO #{table} (SELECT * from #{old_deck_table})"
        connection.drop_table old_deck_table
      end

      private

      def rename_old_tables
        old_tables.each do |old_table_name|
          next unless connection.table_exists? old_table_name
          connection.rename_table old_table_name, table
        end
      end

      def table
        "#{migration_type}_migrations"
      end

      def connection
        ActiveRecord::Base.connection
      end
    end

    def migration_type
      self.class.migration_type || :schema
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
    end

    def down
      raise ActiveRecord::IrreversibleMigration
    end

    private

    def connection
      Cardio::Migration.connection
    end

    def with_migration_table
      yield
    end

    def table_name= table_name
      ActiveRecord::Base.schema_migrations_table_name = table_name
      ActiveRecord::SchemaMigration.table_name = table_name
      ActiveRecord::SchemaMigration.reset_column_information
    end
  end
end
