class Card
  class Cache
    # population-related class methods for Card::Cache
    module Populate
      def populate_ids ids
        # use ids to look up names
        results = Lexicon.cache.read_multi(ids.map(&:to_s)).values
        names = []
        pairs = []
        results.each do |result|
          result.is_a?(String) ? (names << result) : (pairs << result)
        end

        if pairs.any?
          populate_ids pairs.flatten
          names += pairs.map(&:cardname)
        end

        # use keys to look up
        populate_names names
      end

      def populate_names names
        keys = names.map { |n| n.to_name.key }
        Card.cache.read_multi keys
      end

      def populate_fields list, *fields
        name_arrays = list.each_with_object([]) do |item, arrays|
          fields.flatten.each do |field|
            arrays << [item, field]
          end
        end
        populate_names name_arrays
      end

      private

      def populate_temp_cache
        return unless shared_cache

        populate_ids Codename.ids
        # Codename.process_codenames if result.blank?
        Card.cache.read_multi Set.basket[:cache_seed_strings]
        populate_names Set.basket[:cache_seed_names]
      end

      # for testing, stash rules in variable and use that to re-seed cache
      def seed_from_stash
        return unless Cardio.config.seed_cache_from_stash

        stash_to_cache("RULES") { Card::Rule.rule_cache }
        stash_to_cache("READRULES") { Card::Rule.read_rule_cache }
        stash_to_cache("PREFERENCES") { Card::Rule.preference_cache }
      end

      def stash_to_cache variable
        @stash ||= {}
        value = @stash[variable] ||= yield
        Card.cache.temp.write variable, value.clone
      end
    end
  end
end
