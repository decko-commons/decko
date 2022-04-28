module Cardio
  module Schema
    class << self
      def assume_migrated_upto_version type, version=nil
        mode type do |_paths|
          version ||= version type
          ActiveRecord::Schema.assume_migrated_upto_version version
        end
      end

      def migrate type, version=nil, verbose=true
        migration_context type do |mc|
          ActiveRecord::Migration.verbose = verbose
          mc.migrate version
        end
      end

      def suffix type
        case type
        when :core_cards then "_core_cards"
        when :deck_cards then "_deck_cards"
        when :deck then "_deck"
        else ""
        end
      end

      def mode type
        with_suffix type do
          yield migration_paths(type)
        end
      end

      def version type=nil
        path = stamp_path type
        File.exists?(path) ? File.read(path).strip : nil
      end

      def stamp_path type
        root_dir = deck_migration?(type) ? Cardio.root : Cardio.gem_root
        stamp_dir = ENV["SCHEMA_STAMP_PATH"] || File.join(root_dir, "db")

        File.join stamp_dir, "version#{suffix type}.txt"
      end

      def migration_paths type
        list = Cardio.paths["db/migrate#{suffix type}"].to_a
        case type
        when :core_cards
          list += mod_migration_paths "migrate_core_cards"
        when :deck_cards
          list += mod_migration_paths "migrate_cards"
        when :deck
          list += mod_migration_paths "migrate"
        end
        list.flatten
      end

      def migration_context type
        with_suffix type do
          yield ActiveRecord::MigrationContext.new(migration_paths(type),
                                                   ActiveRecord::SchemaMigration)
        end
      end

      private

      def deck_migration? type
        type.in? %i[deck_cards deck]
      end

      def mod_migration_paths dir
        [].tap do |list|
          Mod.dirs.each("db/#{dir}") { |path| list.concat Dir.glob path }
        end
      end

      def with_suffix type, &block
        return yield unless (new_suffix = suffix type).present?

        original_name = ActiveRecord::Base.schema_migrations_table_name
        with_migration_table "#{original_name}#{new_suffix}", original_name, &block
      end

      def with_migration_table new_table_name, old_table_name
        ActiveRecord::Base.schema_migrations_table_name = new_table_name
        ActiveRecord::SchemaMigration.table_name = new_table_name
        ActiveRecord::SchemaMigration.reset_column_information
        yield
      ensure
        ActiveRecord::Base.schema_migrations_table_name = old_table_name
        ActiveRecord::SchemaMigration.table_name = old_table_name
        ActiveRecord::SchemaMigration.reset_column_information
      end
    end
  end
end
