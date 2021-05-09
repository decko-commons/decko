class Card
  module Machine
    REFRESHED = "MACHINE_ASSETS_REFRESHED".freeze

    class << self
      def refresh_script_and_style
        return unless refresh_script_and_style?

        Card.fetch(:all, :script)&.update_if_source_file_changed
        Card.fetch(:all, :style)&.update_if_source_file_changed
      end

      private

      def refresh_script_and_style?
        case Cardio.config.machine_refresh
        when :eager    then true
        when :cautious then cautious_refresh?
        when :never    then false
        else
          raise Card::Error,
                "unknown option for machine_refresh: #{Cardio.config.machine_refresh}"
        end
      end

      # only refresh when cache was cleared
      def cautious_refresh?
        return false unless Card::Cache.persistent_cache
        return false if Card.cache.read REFRESHED

        Card.cache.write REFRESHED, true
      end
    end
  end
end
