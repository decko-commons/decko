require "cardio/commands/card_command"

module Cardio
  module Commands
    class RakeCommand < CardCommand
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
        commands.each do |cmd|
          puts cmd
          # exit_with_child_status cmd

          result = `#{cmd}`
          process = $?
          puts result
          exit process.exitstatus unless process.success?
        end
      end

      def commands
        task_cmd = "bundle exec rake #{@task}"
        return [task_cmd] if !@envs || @envs.empty?
        @envs.map do |env|
          "env RAILS_ENV=#{env} #{task_cmd}"
        end
      end
    end
  end
end

require "cardio/commands/rake_command/parser"
