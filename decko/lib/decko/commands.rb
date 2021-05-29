ENV["DONT_RUN_CARDIO_COMMANDS"]

require "cardio/commands"

module Decko
  class Commands < Cardio::Commands
    self.alias["s"] = "server"
    commands[:rails] << "server"

    new(ARGV).run
  end
end
