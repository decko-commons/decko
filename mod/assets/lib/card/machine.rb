class Card
  module Machine
    REFRESHED = "MACHINE_ASSETS_REFRESHED".freeze

    class << self
      def refresh_assets force: false
        return unless force || refresh_assets?

        refresh_script_assets
        refresh_asset :style, force
      end

      def refresh_script_assets
        Card.search type_id: Card::ModScriptAssetsID do |card|
          # card.update_asset_output
        end
      end

      def refresh_assets!
        refresh_assets force: true
      end

      def reset_all
      end

      def reset_script
      end

      def refresh_asset asset_type, force
        # all_rule(asset_type)&.refresh_output force: force
      end

      private

      def all_rule asset_type
        Card[[:all, asset_type]]
      end

      def refresh_assets?
        case Cardio.config.asset_refresh
        when :eager    then true
        when :cautious then cautious_refresh?
        when :never    then false
        else
          raise Card::Error,
                "unknown option for machine_refresh: #{Cardio.config.asset_refresh}"
        end
      end

      # only refresh when cache was cleared
      def cautious_refresh?
        return false unless Cache.persistent_cache
        return false if Card.cache.read REFRESHED

        Card.cache.write REFRESHED, true
      end
    end
  end
end
