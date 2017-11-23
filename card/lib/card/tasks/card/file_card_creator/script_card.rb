class Card
  class FileCardCreator
    class ScriptCard < AbstractFileCard
      @supported_types = %i[js coffee]
      @category = :script
      @default_rule_name = "*all+*script"

      def source_file_ext
        @type == "coffee" ? "js.coffee" : @type
      end

      def type_codename
        @type_codename ||=
          case @type
          when "js" then :java_script
          when "coffee" then :coffee_script
          end
      end

      def source_file_dir
        File.join "lib", "javascript"
      end
    end
  end
end
