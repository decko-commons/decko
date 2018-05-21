class Card
  class View
    module CacheAction
      # determine action to be used in #fetch

      # course of action based on config/status/options
      # @return [Symbol] :yield, :cache_yield, or
      def cache_action
        log_cache_action do
          send "#{cache_status}_cache_action"
        end
      end

      def log_cache_action
        action = yield
        if false # TODO: make configurable
          puts "VIEW CACHE [#{action}] (#{card.name}##{requested_view})"
        end
        action
      end

      # @return [Symbol] :off, :active, or :free
      def cache_status
        case
        when !cache_on?    then :off    # view caching is turned off, format- or system-wide
        when cache_active? then :active # another view cache is in progress; this view is inside it
        else                    :free   # no other cache in progress
        end
      end


      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # CACHE STATUS: OFF
      # view caching is turned off, format- or system-wide

      # @return [True/False]
      def cache_on?
        Card.config.view_cache && format.class.view_caching?
      end

      # always skip all the magic
      def off_cache_action
        :yield
      end


      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # CACHE STATUS: FREE
      # caching is on; no other cache in progress

      # @return [Symbol]
      def free_cache_action
        free_cache_ok? ? :cache_yield : :yield
      end

      # @return [True/False]
      def free_cache_ok?
        cache_setting != :never && clean_enough_to_cache?
      end

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # CACHE STATUS: ACTIVE
      # another view cache is in progress; this view is inside it

      # @return [Symbol]
      def active_cache_action
        validate_active_cache_action do
          active_cache_ok? ? active_cache_action_from_setting : :stub
        end
      end

      # catch recursive views and invalid stubs
      def validate_active_cache_action
        ok_view == :too_deep ? :yield : yield
        # FIXME: this allows "too deep" error to be cached inside another view.
        # may need a "raise" cache action?
      end

      # @return [True/False]
      def active_cache_ok?
        return false unless parent && clean_enough_to_cache?
        return true if normalized_options[:skip_perms]
        active_cache_permissible?
      end

      # apply any permission checks required by view.
      # (do not cache views with nuanced permissions)
      def active_cache_permissible?
        case permission_task
        when :none                  then true
        when parent.permission_task then true
        when Symbol                 then card.anyone_can?(permission_task)
        else                             false
        end
      end

      # task directly associated with the view in its definition via the
      # "perms" directive
      def permission_task
        @permission_task ||= Card::Format.perms[requested_view] || :read
      end

      # determine the cache action from the cache setting (assuming cache status is "active")
      # @return [Symbol] cache action
      def active_cache_action_from_setting
        level = ACTIVE_CACHE_LEVEL[cache_setting]
        level || raise("unknown cache setting: #{cache_setting}")
      end

      ACTIVE_CACHE_LEVEL = {
        always:   :cache_yield, # read/write cache specifically for this view
        standard: :yield,       # render view; it will only be cached within active view
        never:    :stub         # render a stub
      }.freeze

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # SHARED METHODS

      # Mod developers can configure cache directives on view definitions.  eg:
      #   view :myview, cache: :standard do ...
      #
      # There are three possible values for those rules.
      # * *standard* (default) cache when possible, but avoid double caching
      #   (caching one view while already caching another)
      # * *always* cache whenever possible, even if that means double caching
      # * *never* don't ever cache this view
      #
      # Of these, "never" is most often used explicitly, usually in places
      # where the view can be altered by things other than simple related card changes.
      # It is important to note that to use "never", a view MUST be stubbable (ie, no
      # foreign options). Otherwise the rendering may be involved in an active cache,
      # reach an uncacheable view, attempt to stub it, and fail.
      #
      # @return [Symbol] :standard, :always, or :never
      def cache_setting
        format.view_cache_setting requested_view
      end


      # altered view requests and altered cards are not cacheable
      # @return [True/False]
      def clean_enough_to_cache?
        requested_view == ok_view &&
          !card.unknown? &&
          !card.db_content_changed?
        # FIXME: might consider other changes as disqualifying, though
        # we should make sure not to disallow caching of virtual cards
      end

    end
  end
end
