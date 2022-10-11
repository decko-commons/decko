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
  # This will create a directory following the pattern `DECK_NAME/mod/MOD_NAME`. This
  # directory contains all the specifications of your mod. By default that includes
  # a README.md file and the following subdirectories:
  #
  # - **assets** - for JavaScript, CSS, and variants (CoffeeScript, SCSS, etc)
  # - **lib** - for standard code libraries
  # - **public** - accessible via the web at DECK_URL_ROOT/mod/MOD_NAME/
  # - **set** - the mod's focal point where card sets are configured (see below)
  # - **spec** - for rspec tests
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

    attr_reader :name, :path, :group, :index

    def initialize name, path, group, index
      @name = Mod.normalize_name name
      @path = required_path path
      @group = group || :default
      @index = index
    end

    def mod_card_name
      "mod: #{name.tr '_', ' '}"
    end

    def codename
      "mod_#{name}"
    end

    def subpath *parts
      path = File.join [@path] + parts
      path if File.exist? path
    end

    def tmp_dir type
      File.join Cardio.paths["tmp/#{type}"].first, @group.to_s,
                "mod#{'%03d' % (@index + 1)}-#{@name}"
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

    private

    def required_path path
      return path if File.exist? path

      raise Card::Error::NotFound, "mod not found: #{@name}"
    end
  end
end
