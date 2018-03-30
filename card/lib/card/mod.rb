require_dependency "card/mod/loader"
require_dependency "card/mod/dirs"

class Card
  # A Card Mod (short for "module" or "modification") is a discrete piece of Decko functionality. Mods are how the Decko community develops and shares code. If you want to customize a deck in a way that can't be done on the site itself, try a mod.
  #
  # The simplest way to add a mod is in the `mod` directory of your deck, eg:
  #
  #     DECKNAME/mod/MODNAME
  #
  # In most mods, the focal point is the set modules.
  #
  # ## Set Modules
  #
  # Set modules define methods for a given set of cards and their format objects. They are defined in a mod's _set_ directory. For example, suppose you've created a mod that called *biz*, your deck has Company cards, and you want to extend the behavior of those cards.
  #
  # You can add a set module like so:
  #
  #       card generate set biz type company
  #
  # This will create the following two files:
  #
  #       mod/biz/set/type/company.rb
  #       mod/biz/spec/set/type/company.rb
  #
  # If you would like to break this code into smaller files, you can extend this pattern into another directory, eg:
  #
  #       mod/biz/set/type/company/foo.rb
  #       mod/biz/set/type/company/bar.rb
  #
  # The general pattern can be expressed as follows:
  #
  #       DECKNAME/mod/MODNAME/set/SET_PATTERN/ANCHOR[/FREENAME].rb
  #
  # Learn more:
  #   - {Card} introduces card objects
  #   - {Card::Set} provides an overview of how set modules work
  #   - {Card::Format} explains the basics of the view API
  #   - {Card::Set::Event} explains the basics of the event API
  #
  # ## Other Directories
  #
  # Other ways your mod can extend Decko functionality include:
  #   - **set_pattern** for additional {Card::Set::Pattern set patterns}, or types of sets.
  #   - **format** for creating new formats
  #   - **chunk** provides tools for finding new patterns in card content
  #   - **layouts** can contain hardcoded layouts (layouts are more typically stored in content)
  #   - **lib** for ruby libraries
  #   - **file** for any other supporting files
  #

  module Mod
    class << self
      def load
        return if ENV["CARD_MODS"] == "none"
        if Card.take
          Loader.load_mods
        else
          Rails.logger.warn "empty database"
        end
      end

      # @return an array of Rails::Path objects
      def dirs
        @dirs ||= Dirs.new(Card.paths["mod"].existent)
      end
    end
  end
end
