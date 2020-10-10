require 'cardio/commands/rspec_command'

module Decko
  module Commands
    class RspecCommand < Cardio::Commands::RspecCommand
      class Parser < Cardio::Commands::RspecCommand::Parser
      end
    end
  end
end
