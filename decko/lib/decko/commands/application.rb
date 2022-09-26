require "rails/generators"
require File.expand_path("../../../generators/deck/deck_generator", __FILE__)
require "cardio/commands"

Cardio::Commands.run_non_deck_command ARGV.first, "decko/commands"
