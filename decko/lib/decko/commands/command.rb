# require "English" # needed for CHILD_STATUS, but not sure this is the best place for this.

module Decko
  module Commands
    class Command
      def run
        puts command
        exit_with_child_status command
      end

      def exit_with_child_status command
        command += " 2>&1"
        exit $CHILD_STATUS.exitstatus unless system command
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
