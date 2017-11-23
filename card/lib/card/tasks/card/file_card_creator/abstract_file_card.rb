class Card
  class FileCardCreator
    class AbstractFileCard
      # %w[source_file migration_file ruby_file].each do |f|
      #   require_dependency File.expand_path("../abstract_file_card/#{f}", __FILE__)
      # end

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
        @type = type
        @name = name
        @force = force
        @codename = codename || name.to_name.key
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
