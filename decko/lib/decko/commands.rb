ENV["CARDIO_COMMANDS"] = "NO_RUN"

require "cardio/commands"

module Decko
  class Commands < Cardio::Commands
    extend Cardio::Commands::Accessors
    aliases["s"] = "server"
    commands[:rails] << "server"

    new(ARGV).run
  end
end
