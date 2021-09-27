class Card
  module Assets
    REFRESHED = "ASSETS_REFRESHED".freeze

    class << self
      def refresh_assets force: false
        return unless force || refresh_assets?

        # refresh_script_assets
        # refresh_style_assets
      end

      def refresh_script_assets
        active_script_cards do |script_outputter|
          script_outputter.update_asset_output
        end
      end

      def refresh_style_assets
        style_rule_cards.each do |style_outputter|
          style_outputter.update_asset_output
        end
      end

      def active_script_cards
        Card.search type_id: ["in", LocalScriptFolderGroupID,LocalScriptManifestGroupID]
      end

      def style_rule_cards
        Card.search left: { type_id: SetID }, right_id: StyleID
      end

      def active_theme_cards
        style_rule = { left: { type_id: SetID }, right_id: StyleID }
        Card.search(referred_to_by: style_rule).select do |theme|
          theme.respond_to? :theme_name
        end
      end

      private

      def refresh_assets?
        case Cardio.config.asset_refresh
        when :eager    then true
        when :cautious then cautious_refresh?
        when :never    then false
        else
          raise Card::Error,
                "unknown option for asset refresh: #{Cardio.config.asset_refresh}"
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
