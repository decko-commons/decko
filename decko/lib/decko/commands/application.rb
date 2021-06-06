require "rails/generators"
require "generators/deck/deck_generator"

if ARGV.first != "new"
  ARGV[0] = "--help"
else
  ARGV.shift
end

Decko::Generators::Deck::DeckGenerator.start
