require "cardio/commands"

module Cardio
  # manage different types of commands that can be run via bin/card (and bin/decko)
  class CardCommands < Commands
    new(ARGV).run unless ENV["CARDIO_COMMANDS"] == "NO_RUN"
  end
end
