class Card
  class FileCardCreator
    class StyleCard < AbstractFileCard
      @supported_types = %i[css scss]
      @category = :style
      @default_rule_name = "*all+*style"

      def type_codename
        @type_codename ||= @type.to_sym
      end

      def source_file_dir
        File.join "lib", "stylesheets"
      end
    end
  end
end
