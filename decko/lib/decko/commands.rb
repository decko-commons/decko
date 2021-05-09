# add method in? to Object class
require "active_support/core_ext/object/inclusion"

def load_rake_tasks
  require "./config/environment"
  require "rake"
  Decko::Application.load_tasks
end

RAILS_COMMANDS = %w[ generate destroy plugin benchmarker profiler console
                     server dbconsole application runner ].freeze
DECKO_COMMANDS = %w[new cucumber rspec jasmine].freeze
DECKO_DB_COMMANDS = %w[seed reseed load update].freeze

ALIAS = {
  "rs" => "rspec",
  "cc" => "cucumber",
  "jm" => "jasmine",
  "g" => "generate",
  "d" => "destroy",
  "c" => "console",
  "s" => "server",
  "db" => "dbconsole",
  "r" => "runner"
}.freeze

def supported_rails_command? arg
  arg.in?(RAILS_COMMANDS) || ALIAS[arg].in?(RAILS_COMMANDS)
end

ARGV << "--help" if ARGV.empty?

module Decko
  module Commands
    class << self
      def run_new
        if ARGV.first.in?(["-h", "--help"])
          require "decko/commands/application"
        else
          puts "Can't initialize a new deck within the directory of another, " \
           "please change to a non-deck directory first.\n"
          puts "Type 'decko' for help."
          exit(1)
        end
      end

      def run_rspec
        require "decko/commands/rspec_command"
        RspecCommand.new(ARGV).run
      end

      def run_cucumber
        require "decko/commands/cucumber_command"
        CucumberCommand.new(ARGV).run
      end

      def run_db_task command
        require "decko/commands/rake_command"
        RakeCommand.new("decko:#{command}", ARGV).run
      end

      def run_jasmine
        require "decko/commands/rake_command"
        RakeCommand.new("spec:javascript", envs: "test").run
      end
    end
  end
end

command = ARGV.first
command = ALIAS[command] || command
if supported_rails_command? command
  ENV["PRY_RESCUE_RAILS"] = "1" if ARGV.delete("--rescue")

  # without this, the card generators don't list with: decko g --help
  require "generators/card" if command == "generate"
  require "rails/commands"
else
  ARGV.shift
  case command
  when "--version", "-v"
    puts "Decko #{Card::Version.release}"
  when *DECKO_COMMANDS
    Decko::Commands.send("run_#{command}")
  when *DECKO_DB_COMMANDS
    Decko::Commands.run_db_task command
  else
    puts "Error: Command not recognized" unless command.in?(["-h", "--help"])
    puts <<-EOT
  Usage: decko COMMAND [ARGS]

  The most common decko commands are:
   new         Create a new Decko deck. "decko new my_deck" creates a
               new deck called MyDeck in "./my_deck"
   seed        Create and seed the database specified in config/database.yml

   server      Start the Rails server (short-cut alias: "s")
   console     Start the Rails console (short-cut alias: "c")
   dbconsole   Start a console for the database specified in config/database.yml
               (short-cut alias: "db")

  For core developers
   cucumber     Run cucumber features (short-cut alias: "cc")
   rspec        Run rspec tests (short-cut alias: "rs")
   update       Run card migrations
   load         Load bootstrap data into database

  In addition to those, there are the standard rails commands:
   generate     Generate new code (short-cut alias: "g")
   application  Generate the Rails application code
   destroy      Undo code generated with "generate" (short-cut alias: "d")
   benchmarker  See how fast a piece of code runs
   profiler     Get profile information from a piece of code
   plugin       Install a plugin
   runner       Run a piece of code in the application environment (short-cut alias: "r")

  All commands can be run with -h (or --help) for more information.
    EOT
    exit(1)
  end
end
