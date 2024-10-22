# -*- encoding : utf-8 -*-

class Card
  # The {Cache} class manages and integrates {Temporary} and {Shared}
  # caching. The {Temporary} cache is typically process- and request- specific
  # and is often "ahead" of the database; the {Shared} cache is typically
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
    extend Card::Cache::ClassMethods

    attr_reader :shared, :temp

    # Cache#new initializes a {Temporary} cache, and -- if a :store opt
    # is provided -- a {Shared} cache
    # @param opts [Hash]
    # @option opts [Rails::Cache] :store
    # @option opts [Constant] :class
    def initialize opts={}
      @klass = opts[:class]
      @shared = Shared.new opts if opts[:store]
      @temp = Temporary.new @klass
    end

    # read cache value (and write to temp cache if missing)
    # @param key [String]
    def read key
      @temp.fetch(key) do
        track :read, key do
          @shared&.read key
        end
      end
    end

    def read_multi keys
      return {} unless keys.size > 1

      @temp.fetch_multi keys do |missing_keys|
        track :read_multi, missing_keys do
          @shared ? @shared.read_multi(missing_keys) : {}
        end
      end
    end

    # write to hard (where applicable) and temp cache
    # @param key [String]
    # @param value
    def write key, value
      track :write, key do
        @shared&.write key, value
        @temp.write key, value
      end
    end

    # read and (if not there yet) write
    # @param key [String]
    def fetch key, &block
      @temp.fetch(key) do
        track :fetch, key do
          @shared ? @shared.fetch(key, &block) : yield(key)
        end
      end
    end

    # delete specific cache entries by key
    # @param key [String]
    def delete key
      track :delete, key do
        @shared&.delete key
        @temp.delete key
      end
    end

    # reset both caches (for a given Card::Cache instance)
    def reset
      @shared&.reset
      @temp.reset
    end

    # test for the existence of the key in either cache
    # @return [true/false]
    def exist? key
      @temp.exist?(key) || @shared&.exist?(key)
    end

    private

    def track action, key
      return yield unless (log_action = Cardio.config.cache_log_level)

      key = key.size if key.is_a? Array
      unless log_action == :tally
        Rails.logger.send log_action, "#{action.to_s.upcase} (#{@klass}): #{key}"
      end
      tally action
      yield
    end

    def tally type
      h = Card::Cache.counter ||= {}
      t = h[@klass] ||= {}
      t[type] ||= 0
      t[type] += 1
    end
  end
end
