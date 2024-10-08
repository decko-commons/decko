class Card
  class Cache
    module ClassMethods
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
        Cardio.config.view_cache = true
        Cardio.config.prepopulate_cache = true

        Card::Cache.counter = nil
        return if no_renewal

        renew_persistent
        cache_by_class.each_value do |cache|
          cache.soft.reset
          cache.hard&.renew
        end

        prepopulate_lexicon_caches
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

      def restore
        reset_soft
        prepopulate
      end

      def tallies
        s = "Cache calls ("
        counter.each do |k, v|
          s += "#{k}=#{v} "
        end
        s + ")"
      end

      private

      def prepopulate?
        Cardio.config.prepopulate_cache
      end

      def prepopulate
        return unless prepopulate?

        prepopulate_rule_caches
        prepopulate_lexicon_caches
      end

      def prepopulate_cache variable
        @prepopulated ||= {}
        value = @prepopulated[variable] ||= yield
        Card.cache.soft.write variable, value.clone
      end

      def prepopulate_lexicon_caches
        Card::Lexicon.cache.read_multi Codename.strings.map { |s| "L-#{s}" }
      end

      def prepopulate_rule_caches
        prepopulate_cache("RULES") { Card::Rule.rule_cache }
        prepopulate_cache("READRULES") { Card::Rule.read_rule_cache }
        prepopulate_cache("PREFERENCES") { Card::Rule.preference_cache }
      end

      # generate a cache key from an object
      # @param obj [Object]
      # @return [String]
      def obj_to_key obj
        case obj
        when Hash
          obj.sort.map { |key, value| "#{key}=>(#{obj_to_key(value)})" } * ","
        when Array
          obj.map { |value| obj_to_key(value) }
        else
          obj.to_s
        end
      end
    end
  end
end
