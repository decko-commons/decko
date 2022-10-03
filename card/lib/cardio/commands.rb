require "cardio/command"

# NOTE: the distinction between Cardio::Commands and Cardio::Command is a little awkward
# but not without some justification. Traditionally, there was only Cardio::Commands.
# It was required by both script/card and decko/commands. The problem was that it called
# the run command (see below), which was necessary in the script/card context but
# problematic in the decko/commands context, where we wanted only the superclass instance
# to call #run.

# Since script/card is generated in installations and is hard to update, we didn't want
# to change the name of the file it required, so we kept cardio/commands for that purpose
# and made it inherit from Cardio::Commands, from which Decko::Commands also inherits.

# We could have used CommandsBase (and may yet move to that), but it's worth noting
# that this might have caused its own confusion with CommandBase, a base class for
# classes that handle specific kinds of commands.

module Cardio
  # manage different types of commands that can be run via bin/card (and bin/decko)
  class Commands < Command
    Commands.bin_name = "card"

    new(ARGV).run unless ENV["CARDIO_COMMANDS"] == "NO_RUN"
  end
end
