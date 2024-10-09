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
    extend Card::Cache::ClassMethods

    attr_reader :hard, :soft

    # Cache#new initializes a {Temporary}/soft cache, and -- if a :store opt
    # is provided -- a {Persistent}/hard cache
    # @param opts [Hash]
    # @option opts [Rails::Cache] :store
    # @option opts [Constant] :class
    def initialize opts={}
      @klass = opts[:class]
      @hard = Persistent.new opts if opts[:store]
      @soft = Temporary.new
    end

    # read cache value (and write to soft cache if missing)
    # @param key [String]
    def read key
      unless @soft.exist?(key)
        # Rails.logger.info "READ (#{@klass}): #{key}"
        tally :read
      end

      @soft.fetch(key) { @hard&.read key }
    end

    def read_multi keys
      tally :read_multi
      @soft.fetch_multi keys do |missing_keys|
        @hard ? @hard.read_multi(missing_keys) : {}
      end
    end

    # write to hard (where applicable) and soft cache
    # @param key [String]
    # @param value
    def write key, value
      tally :write
      @hard&.write key, value
      @soft.write key, value
    end

    # read and (if not there yet) write
    # @param key [String]
    def fetch key, &block
      unless @soft.exist?(key)
        # Rails.logger.info "FETCH (#{@klass}): #{key}"
        tally :fetch
      end

      @soft.fetch(key) { @hard ? @hard.fetch(key, &block) : yield(key) }
    end

    # delete specific cache entries by key
    # @param key [String]
    def delete key
      tally :delete
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
      @soft.exist?(key) || @hard&.exist?(key)
    end

    private

    def tally type
      h = Card::Cache.counter ||= {}
      t = h[@klass] ||= {}
      t[type] ||= 0
      t[type] += 1
    end
  end
end
