# require "English" # needed for CHILD_STATUS, but not sure this is the best place for this.

module Cardio
  module Commands
    class Command
      def run
        exit_with_child_status command
      end

      def exit_with_child_status command
        puts command
        command += " 2>&1"
        exit($CHILD_STATUS&.exitstatus || 1) unless system command
      end

      # split special card args and original command args separated by '--'
      def split_args args
        before_split = true
        card_args, command_args =
          args.partition do |a|
            before_split = (a == "--" ? false : before_split)
          end
        command_args.shift
        [card_args, command_args]
      end
    end
  end
end
