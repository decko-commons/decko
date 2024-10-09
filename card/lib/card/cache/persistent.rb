# -*- encoding : utf-8 -*-

class Card
  class Cache
    # _Persistent_ (or _Hard_) caches closely mirror the database and are
    # intended to be altered only upon database alterations.
    #
    # Unlike the database, the persistent cache stores records of records that
    # have been requested but are missing or, in the case of some {Card cards},
    # "virtual", meaning that they follow known patterns but do not exist in the
    # database.
    #
    # Most persistent cache implementations cannot store objects with singleton
    # classes, therefore {Card cards} generally must have set_modules
    # re-included after retrieval from the persistent cache.
    #
    class Persistent
      extend PersistentClass

      attr_accessor :prefix

      # @param opts [Hash]
      # @option opts [Rails::Cache] :store
      # @option opts [ruby Class] :class, typically ActiveRecord descendant
      # @option opts [String] :database
      def initialize opts
        @store = opts[:store]
        @file_cache = @store.is_a? ActiveSupport::Cache::FileStore
        @klass = opts[:class]
        @class_key = @klass.to_s.to_name.key
        @database = opts[:database] || Cardio.database
      end

      # renew insures you're using the most current cache version by
      # reaffirming the stamp and prefix
      def renew
        @stamp = nil
        @prefix = nil
      end

      # reset effectively clears the cache by setting a new stamp.  However
      # unlike annihilate, it won't bother other apps using the same cache engine.
      def reset
        @stamp = self.class.new_stamp
        @prefix = nil
        Cardio.cache.write stamp_key, @stamp
      end

      # the nuclear option. can affect other applications sharing the same
      # cache engine. keep in mind mutually assured destruction.
      def annihilate
        @store.clear
      end

      # the current time stamp. changing this value effectively resets
      # the cache. Note that Cardio.cache is a simple Rails::Cache, not
      # a Card::Cache object.
      def stamp
        @stamp ||= Cardio.cache.fetch(stamp_key) { self.class.new_stamp }
      end

      # key for looking up the current stamp
      def stamp_key
        "#{@database}-#{@class_key}-#{self.class.stamp}-stamp"
      end

      # prefix added to cache key to create a system-wide unique key
      def prefix
        @prefix ||= "#{@database}-#{@class_key}-#{stamp}:"
      end

      # returns prefix/key
      # @param key [String]
      # @return [String]
      def full_key key
        fk = "#{prefix}/#{key}"
        fk.tr! "*", "X" if @file_cache # save for windows fs
        fk
      end

      def read key
        @store.read full_key(key)
      end

      def read_multi keys
        map = keys.each_with_object({}) { |k, h| h[full_key k] = k }
        raw = @store.read_multi(*map.keys)
        raw.each_with_object({}) { |(k, v), h| h[map[k]] = v }
      end

      # update an attribute of an object already in the cache
      # @param key [String]
      # @param attribute [String, Symbol]
      def write_attribute key, attribute, value
        return value unless @store

        # if (object = deep_read key)
        if (object = read key)
          object.instance_variable_set "@#{attribute}", value
          write key, object
        end
        value
      end

      # def deep_read key
      #   binding.pry
      #   # local_cache = @store.send :local_cache
      #   # local_cache&.clear
      #   read key
      # end

      def read_attribute key, attribute
        # object = deep_read key
        object = read key
        object.instance_variable_get "@#{attribute}"
      end

      def write key, value
        @store.write full_key(key), value
      end

      def fetch key, &block
        @store.fetch full_key(key), &block
      end

      def delete key
        @store.delete full_key(key)
      end

      def exist? key
        @store.exist? full_key(key)
      end
    end
  end
end
