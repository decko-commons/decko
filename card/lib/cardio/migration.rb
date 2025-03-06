# -*- encoding : utf-8 -*-

module Cardio
  # Base class for both schema and transform card migrations,
  # which are found in <mod>/data/schema and <mod>/data/transform respectively
  class Migration < ActiveRecord::Migration[6.1]
    include Assumption
    include Stamp
    extend Port

    class << self
      attr_reader :migration_type, :old_tables, :old_deck_table

      def migration_class type
        type == :schema ? Migration::Schema : Migration::Transform
      end

      def new_for type
        migration_class(type).new
      end

      private

      def table
        "#{migration_type}_migrations"
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
        migrations = ActiveRecord::SchemaMigration.new ActiveRecord::Base.connection_pool
        yield ActiveRecord::MigrationContext.new(paths, migrations)
      end
    end

    def mode
      with_migration_table { yield migration_paths }
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
      # ActiveRecord::SchemaMigration.table_name = table_name
      # ActiveRecord::SchemaMigration.reset_column_information
    end
  end
end
