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
        Card.config.prepopulate_cache
      end

      def prepopulate
        return unless prepopulate?

        prepopulate_rule_caches
        # prepopulate_lexicon_caches
      end

      def prepopulate_cache variable
        @prepopulated ||= {}
        value = @prepopulated[variable] ||= yield
        Card.cache.soft.write variable, value.clone
      end

      # def prepopulate_lexicon_caches
      # end

      def prepopulate_rule_caches
        prepopulate_cache("RULES") { Card::Rule.rule_cache }
        prepopulate_cache("READRULES") { Card::Rule.read_rule_cache }
        prepopulate_cache("PREFERENCES") { Card::Rule.preference_cache }
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
