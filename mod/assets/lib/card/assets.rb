class Card
  # Provides methods to refresh script and style assets
  module Assets
    REFRESHED = "ASSETS_REFRESHED".freeze

    class << self
      def inputter_types
        [
          JavaScriptID,
          CoffeeScriptID,
          CssID,
          ScssID
        ]
      end

      def refresh_assets force: false
        return unless force || refresh_assets?

        asset_inputters.each(&:refresh_asset)
        generate_asset_output_files if force
      end

      def make_output_coded
        asset_outputters.each do |card|
          # puts "coding asset output for #{card.name}"
          card.make_asset_output_coded
        end
      end

      def generate_asset_output_files
        asset_outputters.each(&:update_asset_output)
      end

      def asset_inputters
        Card.search(type_id: inputter_types.unshift("in")) +
          Card.search(left: { type: :mod }, right: { codename: %w[in style script] })
      end

      def active_theme_cards
        style_rule = { left: { type_id: SetID }, right_id: StyleID }
        Card.search(referred_to_by: style_rule).select do |theme|
          theme.respond_to? :theme_name
        end
      end

      def script_outputters
        Card.search(left: { type_id: Card::ModID }, right: { codename: "script" })
            .flatten
      end

      def style_outputters
        [Card[:all, :style]]
      end

      def asset_outputters
        script_outputters + style_outputters
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
