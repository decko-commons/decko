# -*- encoding : utf-8 -*-

module Cardio
  module Generators
    # generate structure and card migrations
    class MigrationGenerator < Base
      source_root File.expand_path("templates", __dir__)

      class_option "mod", aliases: "-m", group: :runtime, desc: "mod"

      class_option "schema", type: :boolean, aliases: "-s",
                             default: false, group: :runtime,
                             desc: "Create schema migration"

      def create_migration_file
        set_local_assigns!
        migration_template @migration_template,
                           File.join(mig_paths.first, "#{file_name}.rb")
      end

      protected

      def migration_path
        migration_object.mod_path options["mod"]
      end

      def migration_type
        options["schema"] ? :schema : :transform
      end

      def migration_object
        Migration.new_for migration_type
      end

      # sets the default migration template that is being used for the
      # generation of the migration
      # depending on the arguments which would be sent out in the command line,
      # the migration template
      # and the table name instance variables are setup.

      def set_local_assigns!
        @migration_template = "card_migration.erb"
        @migration_parent_class = Cardio::Migration.migration_class migration_type
        return unless file_name.match?(/^(import)_(.*)(?:\.json)?/)
        @migration_action = Regexp.last_match(1)
        @json_filename = "#{Regexp.last_match(2)}.json"
      end
    end
  end
end
