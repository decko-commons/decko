class Card
  class Cache
    # The {Temporary} cache is intended for a single request, script,
    # migration, etc. It allows you to alter a card and then retrieve
    # the card with those alterations intact _without_ saving those
    # changes to the database.
    #
    # In practice, it's a set of Cache-like methods for using a
    # simple Hash.
    #
    # Unlike the Shared cache, the Temporary cache can handle objects with
    # singleton classes.
    class Temporary
      MAX_KEYS = 10_000
      attr_reader :store

      def initialize klass
        @klass = klass
        @store = {}
        @reps = 0
      end

      # @param key [String]
      def read key
        @store[key]
      end

      # @param key [String]
      def write key, value, callback: true
        within_key_counts do
          @store[key] = value.tap do
            @reps += 1
            @klass.try :after_write_to_temp_cache, value if callback
          end
        end
      end

      # @param key [String]
      def fetch key
        # read(key) || write(key, yield)
        exist?(key) ? read(key) : write(key, yield)
      end

      def fetch_multi keys
        @store.slice(*keys).tap do |found|
          missing = keys - found.keys
          if (newfound = missing.present? && yield(missing))
            found.merge! newfound
            newfound.each { |key, value| write key, value }
          end
        end
      end

      # @param key [String]
      def delete key
        @store.delete key
      end

      def dump
        @store.each do |k, v|
          p "#{k} --> #{v.inspect[0..30]}"
        end
      end

      def reset
        @reps = 0
        @store = {}
      end

      # @param key [String]
      def exist? key
        @store.key? key
      end

      private

      # enforces MAX_KEYS. The @reps count increments with each write but may
      # overestimate the store size, because of multiple writes to the same key.
      # (but this approach avoids recounting each time)
      def within_key_counts
        if @reps >= MAX_KEYS && (@reps = @store.size) > MAX_KEYS
          Rails.logger.info "RESETTING temporary #{@klass} cache. " \
                              "MAX_KEYS (#{MAX_KEYS}) exceeded"
          reset
        end
        yield
      end
    end
  end
end
