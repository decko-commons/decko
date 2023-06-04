# -*- encoding : utf-8 -*-

module Cardio
  module Generators
    # generate structure and card migrations
    class MigrationGenerator < Base
      source_root File.expand_path("templates", __dir__)

      # class_option "mod", aliases: "-m", group: :runtime, desc: "mod"

      class_option "core", type: :boolean, aliases: "-c",
                           default: false, group: :runtime,
                           desc: "Create card migration for card core"

      def create_migration_file
        migration_type = options["core"] ? :core_cards : :deck_cards
        mig_paths = Schema.migration_paths migration_type
        raise "No migration directory for #{migration_type}" if mig_paths.blank?

        set_local_assigns!
        migration_template @migration_template,
                           File.join(mig_paths.first, "#{file_name}.rb")
      end

      protected

      # sets the default migration template that is being used for the
      # generation of the migration
      # depending on the arguments which would be sent out in the command line,
      # the migration template
      # and the table name instance variables are setup.

      def set_local_assigns!
        @migration_template = "card_migration.erb"
        @migration_parent_class =
          options["core"] ?
            "Cardio::Migration::TransformMigration" :
            "Cardio::Migration"
        case file_name
        when /^(import)_(.*)(?:\.json)?/
          @migration_action = Regexp.last_match(1)
          @json_filename    = "#{Regexp.last_match(2)}.json"
        end
      end
    end
  end
end
