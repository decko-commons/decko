require File.expand_path("command_base", __dir__)

module Cardio
  class Command
    # enhance standard RSpec command with some decko/card -specific options
    class RspecCommand < CommandBase
      def initialize args
        require "rspec/core"

        cardio_args, @rspec_args = split_args args
        @opts = {}
        Parser.new(@opts).parse!(cardio_args)
      end

      def command
        "#{env_args} #{@opts[:executer]} #{@opts[:rescue]}" \
          "rspec #{@rspec_args.shelljoin} #{@opts[:files]}"
        # .tap { |c| puts c.yellow }
      end

      private

      def env_args
        ["RAILS_ROOT=.", coverage].compact.join " "
      end

      def coverage
        "CARD_LOAD_STRATEGY=tmp_files" if @opts[:simplecov]
        # # no coverage if rspec was started with file argument
        # "CARD_NO_COVERAGE=true" if @opts[:files] || @opts[:"no-simplecov"]
      end
    end
  end
end

require File.expand_path("rspec_command/parser", __dir__)
