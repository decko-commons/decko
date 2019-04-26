require_dependency "card/view/cache_action"

class Card
  class View
    # View::Cache supports smart card view caching.
    #
    # The basic idea is that when view caching is turned on (via `config.view_cache`),
    # we try to cache a view whenever it's "safe" to do so. We will include everything
    # inside that view (including other views) until we find something that isn't safe.
    # When something isn't safe, we render a "stub": a placeholder with all the info
    # we need to come back and replace it with the correct content later. In this way
    # it is possible to have many levels of cached views within cached views.
    #
    # Here are some things that we never consider safe to cache:
    #
    # 1. an unknown card
    # 2. a card with unsaved content changes
    # 3. a view of a card with view-relevant permission restrictions
    # 4. a view other than the requested view (eg a denial view)
    # 5. a view explicitly configured `never` to be cached
    #
    # We also consider it unsafe to cache one card within another, so nests are always
    # handled with a stub.
    #
    # Cache settings (#5) can be configured in the {AbstractFormat#view view definition}
    # and (less commonly) as a {Card::View::Options view option}.
    #
    # By far, the most common explicit caching configuration is `never`. This setting
    # is used to prevent over-caching, which becomes problematic when data changes
    # do not clear the cache.
    #
    # Generally speaking, a card is smart about clearing its own view caches when
    # anything about the card itself. So when I update the card `Johnny`, all the cached
    # views of `Johnny` are cleared. Similarly, changes to structure rules and other
    # basic patterns are typically well managed by the caching system.
    #
    # However, a card is generally far less smart about clearing its own cache when
    # changes happen to other cards that affect a rule via _logic internal to the view_.
    #
    # For example, consider the following view:
    #
    #      view :myview do
    #        Card["random"].content == "1" ? "2" : "3"
    #      end
    #
    # If this view is cached, and then the card "random" changes, the caching system does
    # not know to clear this cache, so it may be wise to set `cache: :never` in the
    # view definition.
    #
    # Some other common situations likely to require `cache: :never`:
    #
    # 1. view manipulates another rendered view. If the other view generates a stub
    #    then the manipulating view will find itself manipulating a stub.
    #
    #       # obviously safe to cache
    #       view(:x) { "ABC" }
    #
    #       # also safe, because x is not manipulated
    #       view(:y) { render_x + "DEF" }
    #
    #       # unsafe, because x is manipulated
    #       view(:z, cache: :never) { render_z.reverse }
    #
    # 2. view displays a timestamp
    #
    # 3. view is altered by environmental variables
    #
    # 4. view manipulates instance variables that 
    module Cache
      include CacheAction
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
      # If this is a free cache action (see CacheAction), we go through the stubs and
      # render them now.
      # If the cache is active (ie, we are inside another view), we do not worry about
      # stubs but keep going, because the free cache we're inside will take care of
      # those stubs.
      #
      # @return [String (usually)] rendered view
      def cache_render
        cached_view = cache_fetch { yield }
        cache_active? ? cached_view : format.stub_render(cached_view)
      end

      # Is there already a view cache in progress on which this one depends?
      #
      # Note that if you create a brand new independent format object
      # (ie, not a subformat)
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

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
