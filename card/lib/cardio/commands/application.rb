require "rails/generators"
require File.expand_path("../../../generators/deck/deck_generator", __FILE__)

if ARGV.first != "new"
  ARGV[0] = "--help"
else
  ARGV.shift
end

Cardio::Generators::Deck::DeckGenerator.start
