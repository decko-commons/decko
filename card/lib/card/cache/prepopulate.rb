class Card
  class Cache
    # prepulation-related class methods for Card::Cache
    module Prepopulate
      private

      def prepopulate?
        Cardio.config.prepopulate_cache
      end

      def prepopulate
        return unless prepopulate?

        prepopulate_rule_caches
      end

      def prepopulate_cache variable
        @prepopulated ||= {}
        value = @prepopulated[variable] ||= yield
        Card.cache.temp.write variable, value.clone
      end

      def prepopulate_rule_caches
        prepopulate_cache("RULES") { Card::Rule.rule_cache }
        prepopulate_cache("READRULES") { Card::Rule.read_rule_cache }
        prepopulate_cache("PREFERENCES") { Card::Rule.preference_cache }
      end
    end
  end
end
