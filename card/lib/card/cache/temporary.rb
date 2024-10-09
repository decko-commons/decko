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
    # Unlike the Persistent cache, the Temporary cache can handle objects with
    # singleton classes.
    class Temporary
      attr_reader :store

      def initialize
        @store = {}
      end

      # @param key [String]
      def read key
        @store[key]
      end

      # @param key [String]
      def write key, value
        @store[key] = value
      end

      # @param key [String]
      def fetch key
        # read(key) || write(key, yield)
        exist?(key) ? read(key) : write(key, yield)
      end

      def fetch_multi keys
        @store.slice(keys).tap do |found|
          missing = keys - found.keys
          if missing.present?
            if (newfound = yield missing).present?
              found.merge! newfound
              @store.merge! newfound
            end
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
        @store = {}
      end

      # @param key [String]
      def exist? key
        @store.key? key
      end
    end
  end
end
