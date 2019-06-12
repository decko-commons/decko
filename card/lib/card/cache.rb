# -*- encoding : utf-8 -*-

class Card
  class << self
    def cache
      Card::Cache[Card]
    end
  end

  # The {Cache} class manages and integrates {Temporary} and {Persistent}
  # caching. The {Temporary} cache is typically process- and request- specific
  # and is often "ahead" of the database; the {Persistent} cache is typically
  # shared across processes and tends to stay true to the database.
  #
  # Any ruby Class can declare and/or retrieve its own cache as follows:
  #
  # ```` Card::Cache[MyClass] ````
  #
  # Typically speaking, mod developers do not need to use the Cache classes
  # directly, because caching is automatically handled by Card#fetch
  #
  class Cache
    extend Card::Cache::Prepopulate

    @@cache_by_class = {}
    cattr_reader :cache_by_class

    class << self
      attr_accessor :no_renewal

      # create a new cache for the ruby class provided
      # @param klass [Class]
      # @return [{Card::Cache}]
      def [] klass
        raise "nil klass" if klass.nil?

        cache_type = persistent_cache || nil
        cache_by_class[klass] ||= new class: klass, store: cache_type
      end

      def persistent_cache
        return @persistent_cache unless @persistent_cache.nil?

        @persistent_cache =
          case
          when ENV["NO_RAILS_CACHE"]          then false
          when Cardio.config.persistent_cache then Cardio.cache
          else                                     false
          end
      end

      # clear the temporary caches and ensure we're using the latest stamp
      # on the persistent caches.
      def renew
        return if no_renewal
        renew_persistent
        cache_by_class.each_value do |cache|
          cache.soft.reset
          cache.hard&.renew
        end
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
        Cardio.delete_tmp_files!
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

    attr_reader :hard, :soft

    # Cache#new initializes a {Temporary}/soft cache, and -- if a :store opt
    # is provided -- a {Persistent}/hard cache
    # @param opts [Hash]
    # @option opts [Rails::Cache] :store
    # @option opts [Constant] :class
    def initialize opts={}
      @klass = opts[:class]
      cache_by_class[@klass] = self
      @hard = Persistent.new opts if opts[:store]
      @soft = Temporary.new
    end

    # read cache value (and write to soft cache if missing)
    # @param key [String]
    def read key
      @soft.read(key) ||
        (@hard && (ret = @hard.read(key)) && @soft.write(key, ret))
    end

    # write to hard (where applicable) and soft cache
    # @param key [String]
    # @param value
    def write key, value
      @hard&.write key, value
      @soft.write key, value
    end

    # read and (if not there yet) write
    # @param key [String]
    def fetch key, &block
      @soft.fetch(key) { @hard ? @hard.fetch(key, &block) : yield }
    end

    # delete specific cache entries by key
    # @param key [String]
    def delete key
      @hard&.delete key
      @soft.delete key
    end

    # reset both caches (for a given Card::Cache instance)
    def reset
      @hard&.reset
      @soft.reset
    end

    # test for the existence of the key in either cache
    # @return [true/false]
    def exist? key
      @soft.exist?(key) || (@hard&.exist?(key))
    end
  end
end
