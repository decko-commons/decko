class Card
  class FileCardCreator
    class AbstractFileCard
      # Module that provides #create_ruby_file method for a classes that
      # inherit from AbstractFileCard.
      # The default location for the ruby file is set/self.
      module RubyFile
        def create_ruby_file
          write_to_mod(ruby_file_dir, ruby_file_name) do |f|
            f.puts ruby_file_content
          end
        end

        private

        def ruby_file_dir
          File.join "set", "self"
        end

        def ruby_file_name
          @codename + ".rb"
        end

        def ruby_file_content
          "include_set Abstract::CodeFile"
        end
      end
    end
  end
end
