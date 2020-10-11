
if ARGV.first != "new"
  require 'cardio/commands' # .../commands/card_command ?

else
  require "rails/generators"
  require File.expand_path("../../generators/deck/deck_generator", __FILE__)

  ARGV.shift

  Decko::Generators::Deck::DeckGenerator.start
end

