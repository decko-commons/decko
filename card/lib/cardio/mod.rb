require "cardio/mod/class_methods"

module Cardio
  # A Card Mod (short for "module" or "modification") is a library containing discrete
  # chunk of card functionality. Mods are how the Decko community develops and shares
  # code. If you want to customize a deck in a way that can't be done on the site itself,
  # try a mod.
  #
  # The simplest way to add a mod is to run this command in your deck:
  #
  #     card generate mod MOD_NAME
  #
  #     # or, for short:
  #     card g mod MOD_NAME
  #
  # This will create a directory following the pattern `DECK_NAME/mod/MOD_NAME`. This
  # directory contains all the specifications of your mod. By default that includes
  # a README.md file and the subdirectories in **bold** below:
  #
  # - {file:mod/assets/README.md **assets**}
  #   - **script** - JavaScript, CoffeeScript, etc
  #   - **style** - CSS, SCSS, etc
  # - **config**
  #    - **early** ruby init files loaded before Card
  #    - **late** ruby init files loaded after Card
  #    - **locales** i18n yml files
  # - {file:SEEDME.md **data**} - seed and test data.
  # - **lib** - standard ruby libraries
  #   - task - rake tasks
  # - **public** - accessible via the web at DECK_URL_ROOT/mod/MOD_NAME/
  # - **{Card::Set set}** - the mod's focal point where card sets are configured
  # - {Card::Set::Pattern set_pattern} - (advanced) for adding types of sets.
  # - {file:CONTRIBUTING.md#Testing **spec**} - for rspec tests
  # - vendor - for external code, especially git submodules
  #
  # Mods also often contain a .gemspec file to specify the mod as a ruby gem.
  #
  # Learn more:
  #
  #   - {Card} introduces card objects
  #   - {Card::Set} explains of how set modules work
  class Mod
    extend ClassMethods

    attr_reader :name, :path, :group, :index, :spec

    def initialize name, path, group, index, spec=nil
      @name = Mod.normalize_name name
      @path = required_path path
      @group = group || :custom
      @index = index
      @spec = spec
    end

    def mod_card_name
      "mod: #{name.tr '_', ' '}"
    end

    def codename
      "mod_#{name}"
    end

    def subpath *parts, force: false
      path = File.join [@path] + parts
      return path if File.exist? path
      return unless force

      FileUtils.mkdir_p path
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

      raise StandardError, "mod not found: #{@name}"

      # FIXME: - need non-Card based error class
      # raise Card::Error::NotFound,
    end
  end
end
