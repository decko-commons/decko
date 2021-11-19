ENV["CARDIO_COMMANDS"] = "NO_RUN"

require "cardio/commands"

module Decko
  class Commands < Cardio::Commands
    def map
      @map ||= super.merge(
        server: { desc: "start a local web server", group: :shark, alias: :s },
        cucumber: { desc: "run cucumber tests", group: :monkey, alias: :cc, via: :call}
      )
    end

    def generator_requirement
      "decko/generators"
    end

    def gem
      "decko"
    end

    def run_cucumber
      require "decko/commands/cucumber_command"
      CucumberCommand.new(args).run
    end

    def run_version
      puts "Decko #{Cardio::Version.release}".light_cyan
    end

    new(ARGV).run
  end
end
