class Card
  class View
    # View::Cache supports smart card view caching.
    #
    # The basic idea is that when view caching is turned on (via `config.view_cache`),
    # we try to cache a view whenever it's "safe" to do so. We will include everything
    # inside that view (including other views) until we find something that isn't safe.
    # When something isn't safe, we render a {Stub stub}: a placeholder
    # with all the info we need to come back and replace it with the correct content
    # later. In this way it is possible to have many levels of cached views within
    # cached views.
    #
    # Here are some things that we never consider safe to cache:
    #
    # 1. a view explicitly configured _never_ to be cached
    # 2. a view of a card with view-relevant permission restrictions
    # 3. a view other than the requested view (eg a denial view)
    # 4. a card with unsaved content changes
    #
    # We also consider it unsafe to cache a view of one card within a view of a different
    # card, so nests are always handled with a stub.
    #
    # ## Cache configuration
    #
    # Cache settings (#5) can be configured in the
    # {Set::Format::AbstractFormat#view view definition}
    # and (less commonly) as a {Card::View::Options view option}.
    #
    # By far, the most common explicit caching configuration is `:never`. This setting
    # is used to prevent over-caching, which becomes problematic when data changes
    # do not clear the cache.
    #
    # Generally speaking, a card is smart about clearing its own view caches when
    # anything about the card itself. So when I update the card "Johnny", all the cached
    # views of "Johnny" are cleared. Similarly, changes to structure rules and other
    # basic patterns are typically well managed by the caching system.
    #
    # However, there are many other potential changes that views cannot detect. Views that
    # are susceptible to these "cache hazards" should be configured with `cache: :never`.
    #
    # ## Cache hazards
    #
    # If a view contains any of the following cache hazards, it would be wise to consider
    # a `cache: :never` configuration:
    #
    # - dynamic searches (eg `Card.search`) whose results may change
    # - live timestamps (eg `Time.now`)
    # - environmental variables (eg `Env.params`)
    # - any variables altered in one view and used in another (eg `@myvar`)
    # - other cards' properties (eg `Card["random"].content`)
    #
    # What all of the above have in common is that they involve changes about which the
    # view caching system is unaware. This means that whether the cache hazard is
    # rendered directly in a view or just used in its logic, it can change in a way
    # that _should_ change the view but _won't_ change the view if it's cached.
    #
    # ## Altering cached views
    #
    # Whereas ignoring cache hazards may cause over-caching, altering cached views
    # may cause outright errors. If a view directly alters a rendered view,
    # it may be dangerous to cache.
    #
    #        # obviously safe to cache
    #        view(:x) { "ABC" }
    #
    #        # also safe, because x is NOT altered
    #        view(:y) { render_x + "DEF" }
    #
    #        # unsafe and thus never cached, because x is altered
    #        view(:z, cache: :never) { render_x.reverse }
    #
    # Specifically, the danger is that the inner view will be rendered as a stub,
    # and the out view will end up altering the stub and not the view.
    #
    # Although alterations should be considered dangerous, they are actually only
    # problematic in situations where the inner view might sometimes render a stub.
    # If the outer view is rendering a view of the _same card_ with all the _same view
    # settings_ (perms, unknown, etc), there will be no stub and thus no error.
    # Remember, however, that a view on a narrow set may inherit view settings
    # from a general set. To be confident that a view alteration is safe, all inherited
    # settings must be taken into account.
    #
    # ## Caching Best Practices
    #
    # Here are some good rules of thumb to make good use of view caching:
    #
    # 1. *Use nests.* If you can show the content of a different card with a nest rather
    #    than by showing the content directly, the caching system will be much
    #    happier with you.
    #
    #        view :bad_idea, cache: :never do
    #          Card["random"].content
    #        end
    #
    #        view :good_idea do
    #          nest :random, view: :core
    #        end
    #
    # 2. *Isolate the cache hazards.*  Consider the following variants:
    #
    #        view :bad_idea, cache: :never do
    #          if morning_for_user?
    #            expensive_good_morning
    #          else
    #            expensive_good_afternoon
    #          end
    #        end
    #
    #        view :good_idea, cache: :never do
    #          morning_for_user? ? render_good_morning : render_good_afternoon
    #        end
    #
    #     In the first example, we have to generate expensive greetings every time we
    #     render the view.  In the second, only the test is not cached.
    #
    # 3. If you must alter view results, consider *generating the view content
    #    in a separate method.*
    #
    #        # First Attempt
    #
    #        view :hash_it_in do
    #          { cool: false }
    #        end
    #
    #        view :bad_idea, cache: :never do
    #          render_badhash.merge sucks: true
    #        end
    #
    #
    #        #Second Attempt
    #
    #        view :hash_it_out do
    #          hash_it_out
    #        end
    #
    #        def hash_it_out
    #          { cool: true }
    #        end
    #
    #        view :good_idea do
    #          hash_it_out.merge rocks: true
    #        end
    #
    #     The first attempt will work fine with caching off but is risky with caching on.
    #     The second is safe with caching on.
    #
    # ## Optimizing with `:always`
    #
    # It is never strictly necessary to use `cache: :always`, but this setting can help
    # optimize your use of the caching system in some cases.
    #
    # Consider the following views:
    #
    #        view(:hat) { "hat" } # ...but imagine this is computationally expensive
    #
    #        view(:old_hat)  { "old #{render_hat}"  }
    #        view(:new_hat)  { "new #{render_hat}"  }
    #        view(:red_hat)  { "red #{render_hat}"  }
    #        view(:blue_hat) { "blue #{render_hat}" }
    #
    # Whether "hat" uses `:standard` or `:always`, the hat varieties (old, new, etc...)
    # will fully contain the rendered hat view in their cache. However, with `:standard`,
    # the other views will each re-render hat without attempting to cache it separately
    # or to find it in the cache.  This could lead to man expensive renderings of the
    # "hat" view.  By contrast, if the cache setting is `:always`, then hat will be
    # cached and retrieved even when it's rendered inside another cached view.
    #
    module Cache
      EXPIRE_VALUES = %i[minute hour day week month].freeze

      require "card/view/cache/cache_action"
      require "card/view/cache/stub"

      include CacheAction
      include Stub

      private

      # render or retrieve view (or stub) with current options
      # @param block [Block] code block to render
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
      def cache_render &block
        cached_view = cache_fetch(&block)
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
      def cache_fetch &block
        caching do
          ensure_cache_key
          self.class.cache.fetch cache_key, &block
        end
      end

      # keep track of nested cache fetching
      def caching &block
        self.class.caching(cache_setting, &block)
      end

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # VIEW CACHE KEY

      def cache_key
        @cache_key ||= [
          format.symbol, format.nest_mode, card_cache_key, options_for_cache_key, timestamp
        ].compact.map(&:to_s).join "-"
      end

      def nest_mode
        mode = format.nest_mode
        mode == :normal ? nil : mode
      end

      def timestamp
        return unless (expire = format.view_setting :expire, requested_view)
        raise "invalid expire setting: #{expire}" unless EXPIRE_VALUES.include? expire

        DateTime.now.send("end_of_#{expire}").to_i
      end

      def cache_setting
        @cache_setting ||= format.view_cache_setting requested_view
      end

      def card_cache_key
        card.real? ? card.id : "#{card.key}-#{card.type_id}"
      end

      # Registers the cached view for later clearing in the event of related card changes
      def ensure_cache_key
        card.ensure_view_cache_key cache_key
      end

      def options_for_cache_key
        hash_for_cache_key(live_options) + ";" + hash_for_cache_key(viz_hash)
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

        def caching setting, &block
          return @caching unless block_given?

          caching_mode setting, &block
        end

        private

        def caching_mode setting
          old_caching = @caching
          # puts "OPEN CACHING from #{old_caching} to #{setting}" unless @caching == :deep
          @caching = setting unless @caching == :deep
          yield
        ensure
          # puts "CLOSE CACHING from #{@caching} to #{old_caching}"
          @caching = old_caching
        end
      end
    end
  end
end
