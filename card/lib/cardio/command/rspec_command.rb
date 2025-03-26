require File.expand_path("command_base", __dir__)
require "cardio"

module Cardio
  class Command
    # enhance standard RSpec command with some decko/card -specific options
    class RspecCommand < CommandBase
      def initialize args
        require "rspec/core"

        super()
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
        if @opts[:simplecov]
          "CARD_LOAD_STRATEGY=tmp_files"
        elsif @opts[:files]
          # explicitly no coverage if rs pec was started with file argument
          "CARD_SIMPLECOV=false"
        end
      end
    end
  end
end

require File.expand_path("rspec_command/parser", __dir__)
