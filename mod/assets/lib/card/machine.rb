class Card
  module Machine
    REFRESHED = "MACHINE_ASSETS_REFRESHED".freeze

    class << self
      def refresh_assets force: false
        return unless force || refresh_assets?

        refresh_asset :script, force
        refresh_asset :style, force
      end

      def refresh_assets!
        refresh_assets force: true
      end

      def reset_all
        Auth.as_bot do
          Card.search(right: { codename: "machine_output" }).each do |card|
            card.update_columns trash: true
            card.expire
          end
        end
        reset_virtual_machine_cache
      end

      def reset_script
        Auth.as_bot do
          card = Card[:all, :script, :machine_output]
          if card
            card.update_columns trash: true
            card.expire
            reset_virtual_machine_cache
          end
        end
      end

      def refresh_asset asset_type, force
        all_rule(asset_type)&.refresh_output force: force
      end

      private

      def all_rule asset_type
        Card[[:all, asset_type]]
      end

      def reset_virtual_machine_cache
        Virtual.where(right_id: MachineCacheID).delete_all
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
