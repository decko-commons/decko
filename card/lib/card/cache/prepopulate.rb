class Card
  class Cache
    # pre-populate cache for testing purposes
    module Prepopulate
      def restore
        reset_soft
        prepopulate
      end

      private

      def prepopulate?
        Cardio.config.prepopulate_cache
      end

      def prepopulate
        return unless prepopulate?
        prepopulate_rule_caches
        # prepopulate_card_cache
      end

      def prepopulate_cache variable
        @prepopulated ||= {}
        value = @prepopulated[variable] ||= yield
        Card.cache.soft.write variable, value
      end

      def prepopulate_rule_caches
        prepopulate_cache("RULES") { Card.rule_cache }
        prepopulate_cache("READRULES") { Card.read_rule_cache }
        prepopulate_cache("USER_IDS") { Card.user_ids_cache }
        prepopulate_cache("RULES") { Card.rule_keys_cache }
      end

      # def prepopulate_card_cache
      #   prepopulate_cache "ALL_CARDS" do
      #     Card.find_each do |card|
      #       Card.write_to_cache card
      #     end
      #     true
      #   end
      # end
    end
  end
end
