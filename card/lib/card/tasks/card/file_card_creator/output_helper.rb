class Card
  class FileCardCreator
    # Helper methods to write to files and the console.
    module OutputHelper
      def write_to_mod rel_dir, filename, &block
        dir = File.join "mod", @mod, rel_dir
        FileUtils.mkdir_p(dir) unless Dir.exist?(dir)

        path = File.join dir, filename
        log_file_action path do
          File.open(path, "w", &block)
        end
      end

      def log_file_action path, &block
        if File.exist?(path) && !@force
          log_file_exists path
        else
          execute_and_log_file_action path, &block
        end
      end

      def execute_and_log_file_action path
        status = File.exist?(path) ? "overridden" : "created"
        yield
        color_puts status, :green, path
      end

      def log_file_exists path
        color_puts "file exists (use 'force=true' to override)", :yellow, path
      end

      # insert content into a file at a given line number
      def write_at fname, at_line, sdat
        open(fname, "r+") do |f|
          (at_line - 1).times do # read up to the line you want to write after
            f.readline
          end
          pos = f.pos # save your position in the file
          rest = f.read # save the rest of the file
          f.seek pos # go back to the old position
          f.puts sdat # write new data & rest of file
          f.puts rest
          color_puts "created", :green, fname
        end
      end

      def color_puts colored_text, color, text=""
        puts "#{colored_text.send(color.to_s)} #{text}"
      end
    end
  end
end
