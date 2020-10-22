require "cardio/commands/command/parser"

module Cardio
  module Commands
    class Command
      def initialize
        require "rails/all"
        super

        @opts = Parser.new.parse(ARGV).options
        @rails_args, @cmd_args =
          if ARGV.include?('--')
            split_args(ARGV)
          else
            [[], ARGV]
          end
      end

      def run_rails command
warn "CARDCMD #{command} #{@cmd_args}"
        puts command, @cmd_args
        exit_with_child_status command
      end

      def exit_with_child_status command
        command += " 2>&1"
        exit $?.exitstatus unless system command
      end

      # split special decko args and original command args separated by '--'
      def split_args args
        before_split = true
        decko_args, command_args =
          args.partition do |a|
            before_split = (a == "--" ? false : before_split)
          end
        command_args.shift
        [decko_args, command_args]
      end
    end
  end
end
