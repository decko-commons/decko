require "optparse"
require "cardio/version"

module Cardio
  class Commands
    module Custom
      private

      def run_new
        if !["-h", "--help"].intersection(args).empty?
          require "cardio/commands/application"
        else
          puts "Can't initialize a new deck within the directory of another, " \
               "please change to a non-deck directory first.\n"
          puts "Type '#{gem}' for help."
          exit 1
        end
      end

      def run_version
        puts "Card #{Version.card_release}".light_cyan
      end

      def run_rspec
        require "cardio/commands/rspec_command"
        RspecCommand.new(args).run
      end

      # def run_jasmine
      #   require "cardio/commands/rake_command"
      #   RakeCommand.new("spec:javascript", envs: "test").run
      # end

      def run_help
        puts "Usage:"
        puts "  #{gem} COMMAND [OPTIONS]".green
        puts
        puts "Run commands with -h (or --help) for more info."

        %i[shark monkey].each do |group|
          puts
          puts "For " + "#{group}s".yellow + ":"
          map.each do |command, conf|
            next unless conf[:group] == group
            puts command_help(command, conf)
          end
          puts
        end
      end

      private

      # formats command string for help text
      def command_help command, conf
        alt = conf[:alias] ? "(or #{conf[:alias]})" : ""
        "    " + command.to_s.ljust(12).light_cyan + alt.ljust(10) + conf[:desc]
      end
    end
  end
end
