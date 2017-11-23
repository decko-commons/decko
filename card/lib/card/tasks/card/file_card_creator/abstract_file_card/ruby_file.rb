class Card
  class FileCardCreator
    class AbstractFileCard
      module RubyFile
        def create_ruby_file
          write_to_mod(ruby_file_dir, ruby_file_name) do |f|
            f.puts ruby_file_content
          end
        end

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
