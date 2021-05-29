ENV["DONT_RUN_CARDIO_COMMANDS"] = "true"

require "cardio/commands"

require "pry"
module Decko
  class Commands < Cardio::Commands
    extend Cardio::Commands::Accessors
    aliases["s"] = "server"
    commands[:rails] << "server"

    new(ARGV).run
  end
end
