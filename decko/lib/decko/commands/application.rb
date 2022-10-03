require "rails/generators"
require File.expand_path("../../../generators/deck/deck_generator", __FILE__)
require "cardio/command"

Cardio::Command.run_non_deck_command ARGV.first, "decko/commands"
