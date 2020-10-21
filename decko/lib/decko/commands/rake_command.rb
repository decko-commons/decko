require File.expand_path("../command", __FILE__)
# require "pry"

module Decko
  module Commands
    class RakeCommand < Command
      def initialize rake_task, args={}
        @task = rake_task
        opts = {}
        if args.is_a? Array
          Parser.new(rake_task, opts).parse!(args)
        else
          opts = args
        end
        @envs = Array(opts[:envs])
      end

      def run
        puts command
        # exit_with_child_status cmd

        result = `#{command}`
        process = $?
        puts result
        exit process.exitstatus unless process.success?
      end

      def command
        @command ||= command_with_env
      end

      def command_with_env
        @envs.inject(task_cmd) do |task_cmd, env|
          "env RAILS_ENV=#{env} #{task_cmd}"
        end
      end

      def task_cmd
        "bundle exec rake #{@task}"
      end
    end
  end
end

require File.expand_path("../rake_command/parser", __FILE__)
