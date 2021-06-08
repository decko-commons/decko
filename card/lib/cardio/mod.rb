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
    attr_reader :name, :path, :index

    def initialize name, path, index
      @name = Mod.normalize_name name
      @path = path
      @index = index
    end

    def card_name
      "mod: #{name}"
    end

    def codename
      "mod_#{name}"
    end

    def script_codename
      "#{codename}_script"
    end

    def tmp_dir type
      File.join Cardio.paths["tmp/#{type}"].first,
                "mod#{'%03d' % (@index + 1)}-#{@name}"
    end

    def public_assets_path
      File.join(@path, "public", "assets")
    end

    def assets_path
      File.join(@path, "assets")
    end

    def ensure_mod_card
      Card::Auth.as_bot do
        unless Card::Codename.exists? codename
          Card.create name: card_name, codename: codename
        end
        ensure_mod_script_card
      end
    end

    def ensure_mod_script_card
      mod_script_card = find_or_create_mod_script_card
      mod_script_card.update_items
      if mod_script_card.item_cards.present?
        Card[:all, :script].add_item! script_codename.to_sym
      else
        mod_script_card.update codename: nil
        mod_script_card.delete update_referers: true
        Card[:all, :script].drop_item! mod_script_card
      end
    end

    def find_or_create_mod_script_card
      if Card::Codename.exists? script_codename
        Card.fetch script_codename.to_sym
      else
        Card.create name: "#{card_name}+*script",
                    type_id: Card::ModScriptAssetsID,
                    codename: script_codename
      end
    end

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
        @dirs ||= Mod::Dirs.new(Cardio.paths["mod"].existent)
      end

      def dependencies name, nickname=true
        return unless (spec = gem_spec name, nickname)

        deps = spec&.dependencies || []
        dep_names = deps.map { |dep| dependencies dep.name, false }
        (dep_names << spec).flatten.compact.uniq
      end

      def each_path &block
        each_simple_path(&block)
        each_gem_path(&block)
      end

      # @return [Hash] in the form{ modname(String) => Gem::Specification }
      def gem_specs
        Bundler.definition.specs.each_with_object({}) do |gem_spec, h|
          h[gem_spec.name] = gem_spec if gem_spec? gem_spec
        end
      end

      def normalize_name name
        name.to_s.sub(/^card-mod-/, "")
      end

      private

      def gem_spec name, nickname=true
        name = "card-mod-#{name}" if nickname && !name.match?(/^card-mod/)
        spec = Gem::Specification.stubs_for(name)&.first
        gem_spec?(spec) ? spec : nil
      end

      def each_simple_path &block
        Cardio.paths["mod"].each do |mods_path|
          Dir.glob("#{mods_path}/*").each(&block)
        end
      end

      def each_gem_path
        gem_specs.each_value do |spec|
          yield spec.full_gem_path
        end
      end

      # @return [True/False]
      def gem_spec? spec
        return unless spec

        spec.name.match?(/^card-mod-/) || spec.metadata["card-mod"].present?
      end
    end
  end
end
