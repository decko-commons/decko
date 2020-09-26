require File.expand_path("../command", __FILE__)

module Card
  module Commands
    class RspecCommand < Command
      def initialize args
        require "rspec/core"
        require "card/application"

        @card_args, @rspec_args = split_args args
        @opts = {}
        Parser.new(@opts).parse!(@card_args)
      end

      def command
        "#{env_args} #{@opts[:executer]} #{@opts[:rescue]}" \
          "rspec #{@rspec_args.shelljoin} #{spec_files_from opts @opts} "\
          "--exclude-pattern \"./card/vendor/**/*\""
      end

      private

      def env_args
        ["RAILS_ROOT=.", coverage].compact.join " "
      end

      def coverage
        # no coverage if rspec was started with file argument
        if (@opts[:files] || @rspec_args.present?) && !@opts[:simplecov]
          @opts[:simplecov] = "COVERAGE=false"
        end
        @opts[:simplecov]
      end

      def spec_files_from_opts opts
         find_mod_specs(opts[:mods]) +
         find_deck_specs(opts[:deck_files]) +
         find_core_specs(opts[:core_files])
      end
      def find_mod_specs mods
      end
      def find_deck_specs files
      end
      def find_core_specs files
      end
    end
  end
end

require File.expand_path("../rspec_command/parser", __FILE__)
