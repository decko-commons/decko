require "html2haml"

class Card
  class FileCardCreator
    class HamlCard < AbstractFileCard
      @supported_types = %i[haml]
      @category = :haml

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
