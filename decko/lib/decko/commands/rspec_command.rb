require 'cardio/commands/rspec_command'

module Decko
  module Commands
    class RspecCommand < Command
      def initialize args
        require "rspec/core"
        require "decko/application"

        @decko_args, @rspec_args = split_args args
        @opts = {}
        Parser.new(@opts).parse!(@decko_args)
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
        # no coverage if rspec was started with file argument
        return unless @opts[:files] || @rspec_args.present?

        "COVERAGE=false"
      end
    end
  end
end
