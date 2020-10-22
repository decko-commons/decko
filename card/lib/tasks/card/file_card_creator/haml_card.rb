require "html2haml"

class Card
  class FileCardCreator
    # Convert a card with html db content to a card with hard-coded haml.
    # It generates three files:
    #   1. a migration file that creates a card with codename
    #   2. a haml file with the converted html
    #   3. a ruby file (=code rule)that ties the haml file to the card
    class HamlCard < AbstractFileCard
      @supported_types = %i[haml]
      @category = :haml

      private

      def type_codename
        @type_codename ||= :html
      end

      def source_file_dir
        File.join "template", "self"
      end

      def source_file_content
        html = super()
        Html2haml::HTML.new(html).render
      end

      def migration_file_content
        <<-RUBY.strip_heredoc
          ensure_card "#{@name}",
                      type_id: #{type_id},
                      codename: "#{@codename}"
        RUBY
      end

      def ruby_file_content
        "include_set Abstract::HamlFile"
      end
    end
  end
end
