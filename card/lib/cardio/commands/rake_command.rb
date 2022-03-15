require File.expand_path("command", __dir__)

module Cardio
  class Commands
    # enhance standard rake command with some decko/card -specific options
    class RakeCommand < Command
      def initialize gem, command, args={}
        @command = command
        @task = "#{gem}:#{command}"
        @args = [args].flatten
        # opts = {}
        # if args.is_a? Array
        #   Parser.new(rake_task, opts).parse!(args)
        # else
        #   opts = args
        # end
        # @envs = Array(opts[:envs])
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
        task_cmd += " -- #{@args.join ' '}" if !@args.empty?
        return [task_cmd] if !@envs || @envs.empty?

        # @envs.map do |env|
        #   "env RAILS_ENV=#{env} #{task_cmd}"
        # end
      end
    end
  end
end

# require File.expand_path("rake_command/parser", __dir__)
