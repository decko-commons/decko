module Cardio
  class Commands
    attr_reader :command, :args

    class << self
      attr_accessor :alias, :commands
    end

    @alias = {
      "rs" => "rspec",
      "cc" => "cucumber",
      "jm" => "jasmine",
      "g"  => "generate",
      "d"  => "destroy",
      "c"  => "console",
      "db" => "dbconsole",
      "r"  => "runner",
      "v"  => "version",
      "h"  => "help"
    }

    @commands = {
      rails: %w[generate destroy plugin benchmarker profiler
                console dbconsole application runner],
      decko: %w[new cucumber rspec jasmine version decko],
      db:    %w[seed reseed load update]
    }

    def initialize args
      @args = args
      @command = self.class.alias[args.first] || args.first
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
      when :db
        run_db_task
      when :decko
        send "run_#{command}"
      else
        unrecognized
      end
      exit 0
    end

    def run_help
      puts File.read(File.expand_path("../commands/USAGE", __FILE__))
    end

    def run_rails
      require "generators/card" if command == "generate"
      require "rails/commands"
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

    def run_cucumber
      require "cardio/commands/cucumber_command"
      CucumberCommand.new(args).run
    end

    def run_db_task
      require "cardio/commands/rake_command"
      RakeCommand.new("decko:#{command}", args).run
    end

    def run_jasmine
      require "cardio/commands/rake_command"
      RakeCommand.new("spec:javascript", envs: "test").run
    end

    def unrecognized
      puts "Error: Command not recognized: #{command}"
      run_help
      exit 1
    end

    new(ARGV).run unless ENV["DONT_RUN_CARDIO_COMMANDS"]
  end
end
