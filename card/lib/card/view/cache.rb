require_dependency "card/view/cache_action"

class Card
  class View
    include CacheAction

    module Cache
      # Support context-aware card view caching.
      #
      # render or retrieve view (or stub) with current options
      # @params &block [Block] render block
      # @return [rendered view or stub]
      def fetch &block
        case cache_action
          when :yield       then yield                # simple render
          when :cache_yield then cache_render(&block) # render to/from cache
          when :stub        then stub                 # render stub
        end
      end

      # Fetch view via cache and, when appropriate, render its stubs
      #
      # If this is a free cache action (see CacheAction), we go through the stubs and render them now.
      # If the cache is active (ie, we are inside another view), we do not worry about stubs but keep going,
      # because the free cache we're inside will take care of those stubs.
      #
      # @return [String (usually)] rendered view
      def cache_render
        cached_view = cache_fetch { yield }
        cache_active? ? cached_view : format.stub_render(cached_view)
      end

      # Is there already a view cache in progress on which this one depends?
      #
      # Note that if you create a brand new independent format object (ie, not a subformat)
      # its activity will be treated as unrelated to this caching/rendering.
      #
      # @return [true/false]
      def cache_active?
        deep_root? ? false : self.class.caching?
      end

      # If view is cached, retrieve it.  Otherwise render and store it.
      # Uses the primary cache API.
      def cache_fetch
        caching do
          self.class.cache.fetch cache_key do
            register_cache_key
            yield
          end
        end
      end

      # keep track of nested cache fetching
      def caching
        self.class.caching(self) { yield }
      end


      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # VIEW CACHE KEY


      def cache_key
        @cache_key ||= [
          card.key, format.class, format.nest_mode, options_for_cache_key
        ].map(&:to_s).join "-"
      end

      # Registers the cached view for later clearing in the event of related card changes
      def register_cache_key
        card.register_view_cache_key cache_key
      end

      def options_for_cache_key
        hash_for_cache_key(live_options) + hash_for_cache_key(viz_hash)
      end

      def hash_for_cache_key hash
        hash.keys.sort.map do |key|
          option_for_cache_key key, hash[key]
        end.join ";"
      end

      def array_for_cache_key array
        # TODO: needs better handling of edit_structure
        #  currently we pass complete structure as nested array
        array.map do |item|
          item.is_a?(Array) ? item.join(":") : item.to_s
        end.sort.join ","
      end

      def option_for_cache_key key, value
        "#{key}:#{option_value_to_string value}"
      end

      def option_value_to_string value
        case value
          when Hash then "{#{hash_for_cache_key value}}"
          when Array then array_for_cache_key(value)
          else value.to_s
        end
      end

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # cache-related Card::View class methods

      module ClassMethods
        def cache
          Card::Cache[Card::View]
        end

        def caching?
          !@caching.nil?
        end

        def caching voo
          old_caching = @caching
          @caching = voo
          yield
        ensure
          @caching = old_caching
        end
      end
    end
  end
end
