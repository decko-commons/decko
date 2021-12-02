class Card
  # Provides methods to refresh script and style assets
  module Assets
    REFRESHED = "ASSETS_REFRESHED".freeze

    class << self
      # FIXME: if we need this (not sure we do? see below), these types should probably
      # be in a basket so that monkeys can add them.
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

        inputters = standard_inputters

        # typically nonstandard inputters are standard cards, so their events
        # should manage normal (non-forced) refreshing.
        # (standard_inputters, by contrast, are in code, so this refreshing is
        # needed eg in development mode to detect changes)
        inputters += nonstandard_inputters if force
        inputters.each(&:refresh_asset)

        generate_asset_output_files if force
      end

      def make_output_coded
        asset_outputters.each(&:make_asset_output_coded)
      end

      def active_theme_cards
        style_rule = { left: { type_id: SetID }, right_id: StyleID }
        Card.search(referred_to_by: style_rule).select do |theme|
          theme.respond_to? :theme_name
        end
      end

      private

      def generate_asset_output_files
        asset_outputters.each(&:update_asset_output)
      end

      def script_outputters
        Card.search(left: { type: :mod }, right_id: ScriptID).flatten
      end

      def style_outputters
        [Card[:all, :style]]
      end

      def asset_outputters
        script_outputters + style_outputters
      end

      # MOD+:style and MOD+:script cards, which represent the assets in MOD/assets/style
      # and MOD/assets/script directories respectively
      def standard_inputters
        @standard_inputter_ids ||=
          Card.search left: { type: :mod }, right_id: [StyleID, ScriptID], return: :id
        @standard_inputter_ids.map(&:card)
      end

      # standalone cards, NOT in mod assets directories
      def nonstandard_inputters
        Card.search type_id: inputter_types.unshift("in")
      end

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
