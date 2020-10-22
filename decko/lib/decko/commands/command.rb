require 'cardio/commands/command'
require 'cardio/commands/command/parser'

module Decko
  module Commands
    class Command < Cardio::Commands::Command
      class Parser < Command::Parser
      end
    end
  end
end
