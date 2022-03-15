require File.expand_path("command", __dir__)

module Cardio
  class Commands
    # enhance standard RSpec command with some decko/card -specific options
    class RspecCommand < Command
      def initialize args
        require "rspec/core"

        cardio_args, @rspec_args = split_args args
        @opts = {}
        Parser.new(@opts).parse!(cardio_args)
      end

      def command
        "#{env_args} #{@opts[:executer]} #{@opts[:rescue]}" \
          "rspec #{@rspec_args.shelljoin} #{@opts[:files]}"
      end

      private

      def env_args
        ["RAILS_ROOT=.", coverage].compact.join " "
      end

      def coverage
        return if @opts[:simplecov]

        # no coverage if rspec was started with file argument
        return unless @opts[:files] || @rspec_args.any?

        "COVERAGE=false"
      end
    end
  end
end

require File.expand_path("rspec_command/parser", __dir__)
