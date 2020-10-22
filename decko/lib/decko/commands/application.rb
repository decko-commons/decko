require "rails/generators"
require File.expand_path("../../generators/deck/deck_generator", __FILE__)

if ARGV.first != "new"
  require File.expand_path("../environment", APP_CONF)
  require "cardio/commands"
else
  ARGV.shift

  Decko::Generators::Deck::DeckGenerator.start
end
