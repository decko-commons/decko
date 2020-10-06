class Card
  # A Card Mod (short for "module" or "modification") is a discrete piece of Decko
  # functionality. Mods are how the Decko community develops and shares code.
  # If you want to customize a deck in a way that can't be done on the site itself,
  # try a mod.
  #
  # The simplest way to add a mod is to run this command in your deck:
  #
  #     decko generate card:mod MOD_NAME
  #
  # This will create the following directories:
  #
  #     DECK_NAME/mod/MOD_NAME
  #     DECK_NAME/mod/MOD_NAME/lib
  #     DECK_NAME/mod/MOD_NAME/public
  #     DECK_NAME/mod/MOD_NAME/set
  #
  # The lib directory contains libraries, of course. And files in the public directory
  # are public and served directly.
  #
  # But in most mods, the focal point is the *set* directory.
  #
  # ## Set Modules
  #
  # Set modules define methods for a given set of cards and their format objects.
  # They are defined in a mod's _set_ directory. For example, suppose you've created a
  # mod that called *biz*, your deck has Company cards, and you want to extend the
  # behavior of those cards.
  #
  # You can add a set module like so:
  #
  #       decko generate set biz type company
  #
  # This will create the following two files:
  #
  #       mod/biz/set/type/company.rb
  #       mod/biz/spec/set/type/company.rb
  #
  # If you would like to break this code into smaller files, you can extend this
  # pattern into another directory, eg:
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
  #   - {Card::Set::Format} explains the basics of the format API
  #   - {Card::Set::Format::AbstractFormat} explains the basics of the view definition API
  #   - {Card::Set::Event:Api} explains the basics of the event API
  #
  # ## Other Directories
  #
  # Other ways your mod can extend Decko functionality include:
  #   - **format** for creating new formats (think file extensions)
  #   - **set_pattern** for additional {Card::Set::Pattern set patterns},
  #     or types of sets.
  #   - **chunk** provides tools for finding new patterns in card content
  #   - **file** for fixed initial card content
  module Mod
    class << self
      def load
        return if ENV["CARD_MODS"] == "none"

        if Card.take
          Cardio::Mod::Loader.load_mods
        else
          Rails.logger.warn "empty database"
        end
      end

      # @return an array of Rails::Path objects
      def dirs
        @dirs ||= Mod::Dirs.new(Cardio.paths["mod"].existent)
      end

      def dependencies name, nickname=true
        return unless (spec = gem_spec name, nickname)
        deps = spec&.dependencies || []
        dep_names = deps.map { |dep| dependencies dep.name, false }
        (dep_names << spec).flatten.compact.uniq
      end

      def gem_spec name, nickname=true
        name = "card-mod-#{name}" if nickname && !name.match?(/^card-mod/)
        spec = Gem::Specification.stubs_for(name)&.first
        Cardio.gem_mod_spec?(spec) ? spec : nil
      end
    end
  end
end
