require_relative "./abstract_file_card"

class Card
  class FileCardCreator
    # Move javascript or coffeescript from the card database to a file.
    # It generates three files:
    #  1. a migration file that ensures the card has a codename and adds it to the
    #     script rule card.
    #  2. a script file with the source code
    #  3. a ruby file (=code rule) that ties the script file to the card
    class ScriptCard < AbstractFileCard
      @supported_types = %i[js coffee]
      @category = :script
      @default_rule_name = "*all+*script"

      private

      def source_file_ext
        @type == :coffee ? "js.coffee" : @type
      end

      def type_codename
        @type_codename ||=
          case @type
          when :js then :java_script
          when :coffee then :coffee_script
          end
      end

      def source_file_dir
        File.join "lib", "javascript"
      end
    end
  end
end
