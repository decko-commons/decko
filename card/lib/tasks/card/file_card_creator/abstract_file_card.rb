require_relative "./output_helper"
require_relative "./abstract_file_card/source_file"
require_relative "./abstract_file_card/ruby_file"
require_relative "./abstract_file_card/migration_file"

class Card
  class FileCardCreator
    # A template class for generating cards that are linked to source files.
    class AbstractFileCard
      include OutputHelper
      include SourceFile
      include MigrationFile
      include RubyFile

      class << self
        attr_reader :supported_types, :category
        attr_accessor :default_rule_name

        def valid_type? type
          supported_types.include? type.to_sym
        end
      end

      def initialize mod, name, type, codename: nil, force: false
        @mod = mod
        @type = type.to_sym
        @name = name
        @force = force
        @codename = codename || name.underscore.tr(" ", "_")
      end

      def create
        create_source_file
        create_ruby_file
        create_migration_file
      end

      def category
        self.class.category
      end

      private

      def rule_card_name
        self.class.default_rule_name
      end
    end
  end
end
