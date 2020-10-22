require "cardio/commands/command"

module Cardio
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
        cmd = command
        puts cmd
        # exit_with_child_status cmd

        result = `#{cmd}`
        process = $?
        puts result
        exit process.exitstatus unless process.success?
      end

      def command
        @envs.inject("bundle exec rake #{@task}") do |task_cmd, env|
          "env RAILS_ENV=#{env} #{task_cmd}"
        end
      end
    end
  end
end

require "cardio/commands/rake_command/parser"
