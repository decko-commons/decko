class Card
  class Cache
    # pre-populate cache for testing purposes
    module Prepopulate
      def restore
        reset_soft
        Card::Lexicon.renew
        prepopulate
      end

      private

      def prepopulate?
        Cardio.config.prepopulate_cache
      end

      def prepopulate
        return unless prepopulate? # && @prepopulated.nil?

        prepopulate_rule_caches
        # prepopulate_lexicon_caches
        # prepopulate_card_cache
      end

      def prepopulate_cache variable
        @prepopulated ||= {}
        value = @prepopulated[variable] ||= yield
        Card.cache.soft.write variable, value.clone
      end

      def prepopulate_lexicon_caches
        prepopulate_cache("ID-TO-KEY") { Card::Lexicon.id_to_key }
        prepopulate_cache("KEY-TO-ID") { Card::Lexicon.key_to_id }
      end

      def prepopulate_rule_caches
        prepopulate_cache("RULES") { Card::Rule.rule_cache }
        prepopulate_cache("READRULES") { Card::Rule.read_rule_cache }
        prepopulate_cache("USER_IDS") { Card::Rule.user_ids_cache }
        prepopulate_cache("RULE_KEYS") { Card::Rule.rule_keys_cache }
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
