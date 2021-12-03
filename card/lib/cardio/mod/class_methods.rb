module Cardio
  class Mod
    # class methods for Cardio::Mod
    module ClassMethods
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
        @dirs ||= Mod::Dirs.new Cardio.paths["mod"].existent
      end

      def fetch mod_name
        dirs.fetch_mod mod_name
      end

      def normalize_name name
        name.to_s.sub(/^card-mod-/, "")
      end

      def missing
        Card.search(type: :mod).reject { |mod_card| fetch mod_card.modname }
      end

      def ensure_uninstalled
        missing.each do |mod_card|
          Card::Auth.as_bot do
            Card[:all, :style].drop_item mod_card
            delete_auto_installed_cards mod_card
          end
        end
      end

      def ensure_installed
        Card::Cache.reset_all
        puts "installing card mods".green
        Cardio.mods.each(&:ensure)
        Card::Assets.refresh_assets force: true
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

      private

      # it would be nice if this were easier...
      def delete_auto_installed_cards mod_card
        auto_installed_cards(mod_card).each do |card|
          card.codename = nil
          card.delete!
        end
      end

      def auto_installed_cards mod_card
        [mod_card].tap do |cards|
          mod_card.each_descendant do |card|
            cards.unshift card
          end
        end
      end

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
