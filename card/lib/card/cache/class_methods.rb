
class Card
  class Cache
    # class methods for Card::Cache
    module ClassMethods
      include Prepopulate

      attr_accessor :no_renewal
      attr_accessor :counter

      # create a new cache for the ruby class provided
      # @param klass [Class]
      # @return [{Card::Cache}]
      def [] klass
        raise "nil klass" if klass.nil?

        cache_by_class[klass] ||= new class: klass, store: (persistent_cache || nil)
      end

      # clear the temporary caches and ensure we're using the latest stamp
      # on the persistent caches.
      def renew
        # TODO: remove these!!!
        # Cardio.config.view_cache = false
        # Cardio.config.asset_refresh = :cautious
        # Cardio.config.prepopulate_cache = true

        Card::Cache.counter = nil
        return if no_renewal

        renew_persistent
        cache_by_class.each_value do |cache|
          cache.soft.reset
          cache.hard&.renew
        end

        seed_codenamed
      end

      def renew_persistent
        Card::Cache::Persistent.renew if persistent_cache
      end

      # reset standard cached for all classes
      def reset
        reset_hard
        reset_soft
      end

      # reset all caches for all classes
      def reset_all
        reset_hard
        reset_soft
        reset_other
      end

      # completely wipe out all caches, often including the Persistent cache of
      # other decks using the same mechanism.
      # Generally prefer {.reset_all}
      # @see .reset_all
      def reset_global
        cache_by_class.each_value do |cache|
          cache.soft.reset
          cache.hard&.annihilate
        end
        reset_other
      end

      # reset the Persistent cache for all classes
      def reset_hard
        Card::Cache::Persistent.reset if persistent_cache
        cache_by_class.each_value do |cache|
          cache.hard&.reset
        end
      end

      # reset the Temporary cache for all classes
      def reset_soft
        cache_by_class.each_value { |cache| cache.soft.reset }
      end

      # reset Codename cache and delete tmp files
      # (the non-standard caches)
      def reset_other
        Card::Codename.reset_cache
        Cardio::Utils.delete_tmp_files!
      end

      def restore
        reset_soft
        prepopulate
      end

      def persistent_on!
        return if @persistent_cache

        @cache_by_class = {}
        @persistent_cache = Cardio.config.persistent_cache && Cardio.cache
      end

      def cache_by_class
        @cache_by_class ||= {}
      end

      def persistent_cache
        return @persistent_cache unless @persistent_cache.nil?

        @persistent_cache = (ENV["NO_RAILS_CACHE"] != "true") && persistent_on!
      end

      def tallies
        "#{tally_total} Cache calls (" + counter.map { |k, v| "#{k}=#{v} " }.join + ")"
      end

      def seed_ids ids
        # use ids to look up names
        names = Lexicon.cache.read_multi(ids.map(&:to_s)).values
        keys = names.map { |n| n.to_name.key }

        # use keys to look up
        Card.cache.read_multi(keys).each do |key, card|
          Lexicon.cache.soft.write "L-#{key}", card.id
        end
      end

      def seed_names names
        keys = names.map { |n| n.to_name.key }
        cards = Card.cache.read_multi keys
        Lexicon.cache.read_multi lexicon_cache_keys(cards)
      end

      private

      def lexicon_cache_keys cards
        cards.each_value.with_object([]) do |card, cache_keys|
          cache_keys << card.id.to_s if card.id.present?
          cache_keys << Lexicon.name_to_cache_key(card.name)
        end
      end

      def tally_total
        counter.values.map(&:values).flatten.sum
      end

      def seed_codenamed
        Cache.seed_ids Codename.ids if persistent_cache
      end
    end
  end
end
