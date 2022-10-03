require "cardio/command"

module Cardio
  # manage different types of commands that can be run via bin/card (and bin/decko)
  class Commands < Command
    Commands.bin_name = "card"

    new(ARGV).run unless ENV["CARDIO_COMMANDS"] == "NO_RUN"
  end
end
