require File.expand_path("command_base", __dir__)
require "shellwords"

module Cardio
  class Command
    # enhance standard rake command with some decko/card -specific options
    class RakeCommand < CommandBase
      def initialize gem, command, args=[]
        super()
        @command = command
        @task = "#{gem}:#{command}"
        @args = [args].flatten
        # opts = {}
        # if args.is_a? Array
        #   Parser.new(rake_task, opts).parse!(args)
        # else
        #   opts = args
        # end
        # # @envs = Array(opts[:envs])
      end

      def run
        commands.each do |cmd|
          # puts cmd
          # exit_with_child_status cmd

          result = `#{cmd}`
          process = $CHILD_STATUS
          puts result
          exit process.exitstatus unless process.success?
        end
      end

      def commands
        task_cmd = "bundle exec rake #{@task}"
        task_cmd += " -- #{escape_args(@args).join ' '}" unless @args.empty?
        puts task_cmd.yellow
        [task_cmd] if !@envs || @envs.empty?

        # @envs.map do |env|
        #   "env RAILS_ENV=#{env} #{task_cmd}"
        # end
      end

      def escape_args args
        args.map do |arg|
          arg.start_with?("-") ? arg : arg.shellescape
        end
      end
    end
  end
end

# require File.expand_path("rake_command/parser", __dir__)
