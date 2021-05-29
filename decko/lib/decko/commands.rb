ENV["CARDIO_COMMANDS"] = "NO_RUN"

require "cardio/commands"

module Decko
  class Commands < Cardio::Commands
    extend Cardio::Commands::Accessors

    commands[:rails] << (aliases["s"] = "server")
    commands[:custom] << (aliases["cc"] = "cucumber")

    def run_cucumber
      require "decko/commands/cucumber_command"
      CucumberCommand.new(args).run
    end

    def rake_prefix
      "decko"
    end

    new(ARGV).run
  end
end
