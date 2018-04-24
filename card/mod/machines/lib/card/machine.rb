class Card
  module Machine
    REFRESHED="MACHINE_ASSETS_REFRESHED".freeze

    class << self
      def refresh_script_and_style
        return unless refresh_script_and_style?
        Card.fetch(:all, :script)&.update_if_source_file_changed
        Card.fetch(:all, :style)&.update_if_source_file_changed
      end

      private

      def refresh_script_and_style?
        Cardio.config.eager_machine_refresh || cautious_refresh?
      end

      def cautious_refresh?
        return false unless Card::Cache.persistent_cache
        return false if Card.cache.read REFRESHED
        Card.cache.write REFRESHED, true
      end
    end
  end
end
