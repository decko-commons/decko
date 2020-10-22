# add method in? to Object class
require "active_support/core_ext/object/inclusion"
require "cardio/commands/command"

module Cardio
  module Commands

    CARD_RAILS_COMMANDS = %w(console rspec dbconsole run)
    CARD_TASK_COMMANDS = %w(card add add_remote refresh_machine_output
                         reset_cache reset_tmp update merge merge_all
                         assume_card_migrations clean clear dump emergency
                         load seed reseed supplement update seed reseed
                         load update).freeze

    module ClassMethods
      def run_rspec
        require "cardio/commands/rspec_command"
        RspecCommand.new(ARGV).run
      end

      def run_task command, ns='card'
        load_rake_tasks
        #require "cardio/commands/application"
        require "cardio/commands/rake_command"
        command = [ns, command]*':' unless command == '-T'
        RakeCommand.new(command, ARGV).run
      end

      def load_rake_tasks
        require "rake"
        require "./config/environment"
        Cardio::Application.load_tasks
      end
    end

    class << self
      include ClassMethods
    end
  end
end

ARGV << "--help" if ARGV.empty?

command = ARGV.first
#FIXME: how to use DECK aliases? maybe they need to be here?
#command = ALIAS[command] || command

ARGV.shift
lookup = command
lookup = $1 if command =~ /^([^:]+):/

case lookup
when "--version", "-v"
  puts "Card #{Card::Version.release}"
when *Cardio::Commands::CARD_RAILS_COMMANDS
  cmd = Cardio::Commands::Command.new
  cmd.run_rails(command) unless cmd.nil?
when '-T', *Cardio::Commands::CARD_TASK_COMMANDS
  Cardio::Commands.run_task command
else
  puts "Error: Command not recognized: #{command}" unless command.in?(["-h", "--help"])
  # FIXME: give mostly card help, card -T to list, rspec, etc. reference decko
  puts <<-EOT
  Usage: card COMMAND [ARGS]

  The most common card commands are: (customized from rails?)
     seed        Create and seed the database specified in config/database.yml

     server      Start the Rails server (short-cut alias: "s")
     console     Start the Rails console (short-cut alias: "c")
     dbconsole   Start a console for the database specified in config/database.yml
               (short-cut alias: "db")

    For core developers
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
