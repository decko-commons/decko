class Card
  class Cache
    # cache-related class methods
    module CardClass
      def cache
        Card::Cache[Card]
      end

      def after_write_to_temp_cache card
        card.write_lexicon if card.is_a? Card
      end

      def retrieve_from_cache cache_key, local_only=false
        local_only ? cache.temp.read(cache_key) : cache.read(cache_key)
      end

      def retrieve_from_cache_by_id id, local_only=false
        key = Card::Lexicon.name(id)&.key
        return unless key.present?

        retrieve_from_cache key, local_only if key
      end

      def retrieve_from_cache_by_key key, local_only=false
        retrieve_from_cache key, local_only
      end

      def write_to_cache card, local_only=false
        if local_only
          write_to_temp_cache card
        elsif cache
          cache.write card.key, card
        end
      end

      def write_to_temp_cache card
        return unless cache

        cache.temp.write card.key, card, callback: false
      end

      def expire name
        key = name.to_name.key
        return unless (card = Card.cache.read key)

        card.expire
      end
    end
  end
end
