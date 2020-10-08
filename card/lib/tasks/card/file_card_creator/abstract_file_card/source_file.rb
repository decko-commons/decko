class Card
  class FileCardCreator
    class AbstractFileCard
      # Module that provides #create_source_file method for a classes that
      # inherit from AbstractFileCard
      module SourceFile
        def create_source_file
          write_to_mod source_file_dir, source_file_name do |f|
            f.puts source_file_content
          end
        end

        private

        def source_file_content
          card = Card.fetch(@name)
          if card
            card.content
          else
            color_puts "warning:", :yellow,
                       "Card '#{@name}' doesn't exist. Creating empty source file ..."
            ""
          end
        end

        def source_file_name
          "#{@codename}.#{source_file_ext}"
        end

        def source_file_ext
          @type
        end
      end
    end
  end
end
