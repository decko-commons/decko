require "English"
require "colorize"
require "cardio/command/custom"

module Cardio
  # manage different types of commands that can be run via bin/card (and bin/decko)
  class Command
    include Custom

    attr_reader :command, :args

    class << self
      attr_accessor :bin_name

      def run_non_deck_command command, commands_script
        if command == "new"
          ARGV.shift
          Cardio::Generators::Deck::DeckGenerator.start
        elsif command.blank?
          require commands_script
        else
          puts "ERROR: `#{bin_name} #{command}` " \
               "cannot be run from outside deck".red
        end
      end
    end

    def map
      @map ||= {
        new: { desc: "create a new deck", group: :shark, via: :call },
        setup: { desc: "populate a database", group: :shark, via: :rake },
        update: { desc: "run data updates", group: :shark, alias: :u, via: :rake },
        version: { desc: "#{gem} gem version", group: :shark, alias: :v, via: :call },
        help: { desc: "show this text", group: :shark, alias: :h, via: :call },

        console: { desc: "start a ruby console", group: :monkey, alias: :c },
        dbconsole: { desc: "start a database console", group: :monkey, alias: :db },
        runner: { desc: "run code in app environment", group: :monkey, alias: :r },
        rspec: { desc: "run rspec tests", group: :monkey, alias: :rs, via: :call },
        generate: { desc: "generate templated code", group: :monkey, alias: :g },
        sow: { desc: "export card data to mod yaml", group: :monkey, via: :rake },
        eat: { desc: "ingest card data from mod yaml", group: :monkey, via: :rake }
      }
    end

    # TODO: review the following. see if any work well enough to include
    #
    #    application  Generate the Rails application code
    #    destroy      Undo code generated with "generate" (short-cut alias: "d")
    #    benchmarker  See how fast a piece of code runs
    #    profiler     Get profile information from a piece of code
    #    plugin       Install a plugin
    #    jasmine

    def initialize args
      @args = args
      @command = command_for_key args.first&.to_sym
      ENV["PRY_RESCUE_RAILS"] = "1" if rescue?
      @args.shift unless handler == :rails
    end

    def gem
      "card"
    end

    def run
      case handler
      when :rails
        run_rails
      when :rake
        run_rake
      when :call
        send "run_#{command}"
      when :unknown
        unknown_error
      end
      exit 0
    end

    private

    def command_for_key key
      return :help unless key
      return key if map.key? key

      map.each { |k, v| return k if v[:alias] == key }
      @unknown = true
      key
    end

    def rescue?
      args.delete "--rescue"
    end

    def config
      map[command]
    end

    def handler
      @handler ||= @unknown ? :unknown : (config[:via] || :rails)
    end

    # runs all commands in "rails" list
    def run_rails
      require generator_requirement if command == :generate
      require "rails/commands"
    end

    def generator_requirement
      "cardio/generators"
    end

    # runs all commands in "rake" list
    def run_rake
      require "cardio/command/rake_command"
      RakeCommand.new(gem, command, args).run
    end

    # ~~~~~~~~~~~~~~~~~~~~~ catch-all -------------- #

    def unknown_error
      puts "----------------------------------------------\n" \
           "ERROR: Command not recognized: #{command}\n" \
           "----------------------------------------------\n".red
      run_help
      exit 1
    end
  end
end
