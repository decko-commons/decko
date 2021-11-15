require "cardio/mod/class_methods"

module Cardio
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
  #   - {Card::Set::Event::Api} explains the basics of the event API
  #
  # ## Other Directories
  #
  # Other ways your mod can extend Decko functionality include:
  #   - **set_pattern** for additional {Card::Set::Pattern set patterns},
  #     or types of sets.
  #   - **file** for fixed initial card content
  class Mod
    extend ClassMethods

    attr_reader :name, :path, :index

    def initialize name, path, index
      @name = Mod.normalize_name name
      @path = required_path path
      @index = index
    end

    def mod_card_name
      "mod: #{name}"
    end

    def codename
      "mod_#{name}"
    end

    def subpath *parts
      path = File.join [@path] + parts
      path if File.exist? path
    end

    def tmp_dir type
      File.join Cardio.paths["tmp/#{type}"].first,
                "mod#{'%03d' % (@index + 1)}-#{@name}"
    end

    def ensure
      Card::Auth.as_bot do
        card = ensure_card
        card.ensure_mod_script_card
        card.ensure_mod_style_card
        Card::Cache.reset_all
      end
    end

    private

    def required_path path
      return path if File.exist? path

      raise Card::Error::NotFound, "mod not found: #{@name}"
    end

    def ensure_card
      if Card::Codename.exists? codename
        card = Card.fetch codename.to_sym
        card.update type: :mod unless card.type_code == :mod
        card
      else
        Card.create name: mod_card_name, type: :mod, codename: codename
      end
    end
  end
end
