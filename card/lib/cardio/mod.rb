require "cardio/mod/class_methods"

module Cardio
  # A Card Mod (short for "module" or "modification") is a library containing discrete
  # chunk of card functionality. Mods are how the Decko community develops and shares
  # code. If you want to customize a deck in a way that can't be done on the site itself,
  # try a mod.
  #
  # The simplest way to add a mod is to run this command in your deck:
  #
  #     card generate card:mod MOD_NAME
  #
  # This will create a directory following the pattern `DECK_NAME/mod/MOD_NAME`. This
  # directory contains all the specifications of your mod. By default that includes
  # a README.md file and the subdirectories in **bold** below:
  #
  # - **assets**
  #   - **script** - JavaScript, CoffeeScript, etc
  #   - **style** - CSS, SCSS, etc
  # - **config**
  #    - **early** init files loaded before Card
  #    - **late** init files loaded after Card
  #    - **locales** i18n yml files
  # - {file:SEEDME.md **data**} - seed and test data.
  # - **lib** - standard code libraries
  #   - task - rake tasks
  # - **public** - accessible via the web at DECK_URL_ROOT/mod/MOD_NAME/
  # - **{Card::Set set}** - the mod's focal point where card sets are configured
  # - {Card::Set::Pattern set_pattern} - (advanced) for adding types of sets.
  # - {file:CONTRIBUTING.md#Testing **spec**} - for rspec tests
  # - vendor - for external code, especially git submodules
  #
  #
  # Learn more:
  #
  #   - {Card} introduces card objects
  #   - {Card::Set} explains of how set modules work
  class Mod
    extend ClassMethods

    attr_reader :name, :path, :group, :index

    def initialize name, path, group, index
      @name = Mod.normalize_name name
      @path = required_path path
      @group = group || :custom
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

      # FIXME: - need non-Card based error class
      raise Card::Error::NotFound, "mod not found: #{@name}"
    end
  end
end
