# add method in? to Object class
require "active_support/core_ext/object/inclusion"

def load_rake_tasks
  require "./config/environment"
  require "rake"
  Card::Application.load_tasks
end

RAILS_COMMANDS = %w( generate destroy plugin benchmarker profiler console
                     server dbconsole application runner ).freeze
DECKO_COMMANDS = %w(new cucumber rspec jasmine).freeze
DECKO_DB_COMMANDS = %w(seed reseed load update).freeze

ALIAS = {
  "rs" => "rspec",
  "cc" => "cucumber",
  "jm" => "jasmine",
  "g"  => "generate",
  "d"  => "destroy",
  "c"  => "console",
  "s"  => "server",
  "db" => "dbconsole",
  "r"  => "runner"
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
          require "card/commands/application"
        else
          puts "Can't initialize a new deck within the directory of another, " \
           "please change to a non-deck directory first.\n"
          puts "Type 'card' for help."
          exit(1)
        end
      end

=begin
# ? all card db and related?
card migrate
card add name, type
card merge [name] # update deck using yaml files
card seed [environment]
card reset
card remote add name, url
card update
card clear
card load

# rails tasks (should be anywhere)
#rails inherited card commands: 
card help, card --help # lists all these commands.
card generate # auto-generate code
card console
card dbconsole
card new
=end

      def run_rspec
        require "card/commands/rspec_command"
        RspecCommand.new(ARGV).run
      end

      def run_cucumber
        require "decko/commands/cucumber_command"
        CucumberCommand.new(ARGV).run
      end

      def run_task command
        require "card/commands/rake_command"
        RakeCommand.new("card:#{command}", ARGV).run
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
=begin
CLI

There are three main groups of commands:
  card commands, eg `card merge`. Note these should not require the decko gem.
  decko commands, which include all the card commands (eg `decko up`)
        AND some others that require the decko gem.
  rake commands, which include (nearly) all the decko commands
        (eg `rake decko:update`) AND some additional rarely used commands
        for platypuses. Some special cases may not be executable as rake
        commands (eg decko new(?))

card merge [name] # update deck using yaml files
 -m  --mod        # only merge cards in given mod
 -c  --card       # compare timestamps on a card-by-card basis
                  # (not mod-by-mod). not needed if name provided
 -f  --force      # up every card without timestamp comparisons
 -e  --env        # environment (test, production, etc).  default: all
 -h  --help 
 
Heir of `rake card:merge` – it’s how fixtures turn into card data. If no
args, use mod-specific timestamp checks to figure out which cards should
be run. If name is provided, updates only one card.

card grab mark    # download card from remote sources 
 -m  --mod        # output yaml to mod (otherwise stdout)
 -u  --url        # source card details from url
 -r  --remote     # same as url, but with registered remote url
 -l  --local      # source card details from local db
 -e  --env        # environment (if local. default to dev?)
 -n  --nest       # also grab cards nested by <name>
 -i  --items      # only grab cards nested by <name>
                  # both -n and -i can specify a depth
 -f  --(code)file # add rb and content files
 -h  --help

card add name, type
  -c --codename   # specify codename (otherwise generate from name)
  -p --policy     #
 
card generate # auto-generate code
  mod name
  set mod pattern anchor1 [, anchor2, anchor3..]
  format mod name
  migration name
    -m  --mod
  codefile [type]  

We should make the most important mod-developer operations really easy to remember and use.  (decko generate card:set is much harder to remember than card generate set).  set and mod are definitely the most important of these two.

card migrate
 -g --gem         # gem only
 -d --deck        # decko only
 -m --mod         # mod only
 -e --environment
 -v --version
    --verbose  
 -s --stamp 
 -r --redo        # redo migration to version
    --status      # see rails db:migrate:status

card seed [environment]
 -s --scratch     # drop and re-create database (default)
 -r --reseed      # clear and reload fixtures with existing tables
 -e --environment
 -a --all         # all environments
 -d --development # shorthand for `-e development`
 -p --production
 -t --test 

card reset
 -m --machines
 -c --cache
 -t --tmpfiles
 -a --all      # default

card remote add name, url
            drop name
            list


card update
Call card:migrate, card:merge, and card:reset. 

card help, card --help # lists all these commands.
card version, card --version

card rspec
 -d --deck-spec FILENAME(:LINE)  # Run spec for a Decko decko file
 -c --core-spec FILENAME(:LINE)  # Run spec for a Decko core file
 -m --mod MODNAME 			# Run all specs for a mod 
 -s --[no-]simplecov	           # Run with simplecov
    --rescue                     # Run with pry-rescue
    --[no]-spring                # Run with spring

card console
card dbconsole
card new
card clear
card load

decko commands:
decko cucumber
decko server
...

...and some commands have a slightly different meaning in decko:

decko update
 -s --symlinks # update symlinks only

Call card update and rake decko:reset:symlinks

Note: it would be nice if commands with mod-specific options (merge, grab, generate, etc) could be smart about the current mod they’re in if called from within a mod.


rake commands

Rake is clearly a powerful tool for organizing a quick api for tasks that are sometimes performed independently and other times as part of a larger process.  We wouldn’t want to write separate scripts for all those tasks.


The Decko / Card rake tasks spreadsheet lays out how all the old tasks will be handled in the new system. 
Additional Notes
Every `card task` call should also be callable as `rake card:task`. 
Every `decko task` call should also be callable as `rake decko:task`. 
Every `rake card:task` call should also be callable as `rake decko:task`.  (but not necessarily vice versa)
We will need to use OptionParser in rake to be able to mimic the argument handling of the card and decko commands.
`rake -T` should
=end
