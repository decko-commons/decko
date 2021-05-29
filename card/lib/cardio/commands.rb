require "English"

module Cardio
  class Commands
    attr_reader :command, :args

    module Accessors
      def aliases
        @aliases ||= {
          "rs" => "rspec",
          "jm" => "jasmine",
          "g"  => "generate",
          "d"  => "destroy",
          "c"  => "console",
          "db" => "dbconsole",
          "r"  => "runner",
          "v"  => "version",
          "h"  => "help"
        }
      end

      def commands
        @commands ||= {
          rails:  %w[generate destroy plugin benchmarker profiler
                     console dbconsole application runner],
          rake:   %w[seed reseed load update],
          custom: %w[new rspec jasmine version help]
        }
      end
    end

    extend Accessors

    def initialize args
      @args = args
      @command = self.class.aliases[args.first] || args.first
      ENV["PRY_RESCUE_RAILS"] = "1" if rescue?
      @args.shift unless handler == :rails
    end

    def rescue?
      args.delete "--rescue"
    end

    def handler
      commands = self.class.commands
      @handler ||= commands.keys.find { |k| commands[k].include? command }
    end

    def run
      case handler
      when :rails
        run_rails
      when :rake
        run_rake
      when :custom
        send "run_#{command}"
      else
        unrecognized
      end
      exit 0
    end

    # runs all commands in "rails" list
    def run_rails
      require "generators/card" if command == "generate"
      require "rails/commands"
    end

    # runs all commands in "rake" list
    def run_rake
      require "cardio/commands/rake_command"
      RakeCommand.new("#{rake_prefix}:#{command}", args).run
    end

    def rake_prefix
      "card"
    end

    # ~~~~~~~~~ CUSTOM COMMANDS ~~~~~~~~~~~~ #

    def run_help
      puts File.read(File.expand_path("../commands/USAGE", __FILE__))
    end

    def run_new
      if ["-h", "--help"].include? args.first
        require "cardio/commands/application"
      else
        puts "Can't initialize a new deck within the directory of another, " \
         "please change to a non-deck directory first.\n"
        puts "Type 'decko' for help."
        exit 1
      end
    end

    def run_version
      require "card/version"
      puts "Decko #{Card::Version.release}"
    end

    def run_rspec
      require "cardio/commands/rspec_command"
      RspecCommand.new(args).run
    end

    def run_jasmine
      require "cardio/commands/rake_command"
      RakeCommand.new("spec:javascript", envs: "test").run
    end

    # ~~~~~~~~~~~~~~~~~~~~~ catch-all -------------- #

    def unrecognized
      puts "Error: Command not recognized: #{command}"
      run_help
      exit 1
    end

    new(ARGV).run unless ENV["CARDIO_COMMANDS"] == "NO_RUN"
  end
end
