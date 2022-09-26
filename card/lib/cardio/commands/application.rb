require "rails/generators"
require File.expand_path("../../../generators/deck/deck_generator", __FILE__)

if ARGV.first == "new"
  ARGV.shift
  Cardio::Generators::Deck::DeckGenerator.start
elsif ARGV.first.blank?
  require "cardio/card_commands"
else
  puts "ERROR: `card #{ARGV.first}` must be run from within deck".red
end
