# -*- encoding : utf-8 -*-

class Card
  class << self
    def cache
      Card::Cache[Card]
    end

    def after_write_to_temp_cache card
      card.write_lexicon if card.is_a? Card
    end
  end

  def write_lexicon
    return unless id.present?
    # without this return, we have trash problems. The issue is that the lexicon and
    # card cashes don't have very compatible trash handling yet. The lexicon returns
    # an id even for trashed cards; the card cache returns a new card.

    temp = Lexicon.cache.temp
    temp.write id.to_s, name if name.present?
    lx = lex
    temp.write Lexicon.cache_key(lx), id if lx
  end

  def lex
    if simple?
      name
    elsif left_id && right_id
      [left_id, right_id]
    end
  end

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
      unless @temp.exist?(key)
        Rails.logger.info "READ (#{@klass}): #{key}"
        tally :read
      end

      @temp.fetch(key) { @shared&.read key }
    end

    def read_multi keys
      tally :read_multi
      @temp.fetch_multi keys do |missing_keys|
        @shared ? @shared.read_multi(missing_keys) : {}
      end
    end

    # write to hard (where applicable) and temp cache
    # @param key [String]
    # @param value
    def write key, value
      tally :write
      @shared&.write key, value
      @temp.write key, value
    end

    # read and (if not there yet) write
    # @param key [String]
    def fetch key, &block
      unless @temp.exist?(key)
        # Rails.logger.info "FETCH (#{@klass}): #{key}"
        tally :fetch
      end

      @temp.fetch(key) { @shared ? @shared.fetch(key, &block) : yield(key) }
    end

    # delete specific cache entries by key
    # @param key [String]
    def delete key
      tally :delete
      @shared&.delete key
      @temp.delete key
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

    def tally type
      h = Card::Cache.counter ||= {}
      t = h[@klass] ||= {}
      t[type] ||= 0
      t[type] += 1
    end
  end
end
