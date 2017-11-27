class Card
  class FileCardCreator
    # Move css or scss from the card database to a file.
    # It generates three files:
    #  1. a migration file that ensures the card has a codename and adds it to the
    #     style rule card.
    #  2. a style file with the source code
    #  3. a ruby file (=code rule) that ties the style file to the card
    class StyleCard < AbstractFileCard
      @supported_types = %i[css scss]
      @category = :style
      @default_rule_name = "*all+*style"

      private

      def type_codename
        @type_codename ||= @type.to_sym
      end

      def source_file_dir
        File.join "lib", "stylesheets"
      end
    end
  end
end
