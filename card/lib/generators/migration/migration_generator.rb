# -*- encoding : utf-8 -*-

module Cardio
  module Generators
    # generate structure and card migrations
    class MigrationGenerator < ActiveRecord::Generators::Base
      extend ClassMethods

      source_root File.expand_path("templates", __dir__)

      argument :name, required: true

      class_option "mod", aliases: "-m", group: :runtime, desc: "mod", required: true

      class_option "schema",
                   type: :boolean, lazy_default: true, group: :runtime,
                   desc: "Create schema migration"

      def create_migration_file
        set_local_assigns!
        migration_template "card_migration.erb",
                           File.join(migration_path, "#{file_name}.rb")
      end

      protected

      def mod_object
        @mod_object ||= Cardio::Mod.fetch(options[:mod]) || raise("unknown mod: #{mod}")
      end

      def migration_path
        mod_object.subpath "data", migration_type.to_s, force: true
      end

      def migration_type
        options["schema"] ? :schema : :transform
      end

      def migration_object
        Migration.new_for migration_type
      end

      def set_local_assigns!
        @migration_parent_class = Cardio::Migration.migration_class migration_type
      end
    end
  end
end
