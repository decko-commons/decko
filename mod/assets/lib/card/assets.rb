class Card
  module Assets
    REFRESHED = "ASSETS_REFRESHED".freeze

    class << self
      def inputter_types
        [
          JavaScriptID,
          CoffeeScriptID,
          CssID,
          ScssID,
        ]
      end

      def refresh_assets force: false
        return unless force || refresh_assets?

        asset_inputters.each(&:refresh_asset)
        generate_asset_output_files if force
      end

      def generate_asset_output_files
        asset_outputters.each(&:update_asset_output)
      end

      def asset_inputters
        Card.search(type_id: inputter_types.unshift("in")) +
          Card.search(left: { type_id: Card::ModID }, right: { codename: "style" })
      end

      def active_theme_cards
        style_rule = { left: { type_id: SetID }, right_id: StyleID }
        Card.search(referred_to_by: style_rule).select do |theme|
          theme.respond_to? :theme_name
        end
      end

      def asset_outputters
        outputters =
          Card.search(left: { type_id: Card::ModID }, right: { codename: "script" })
              .flatten
        outputters << Card[:all, :style]
        outputters
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
