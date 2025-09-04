class Card
  class View
    module Cache
      # determine action to be used in #fetch
      module CacheAction
        ACTIVE_CACHE_LEVEL =
          { always: :cache_yield,
            deep: :cache_yield,
            force: :cache_yield,
            default: :yield,
            yes: :yield,
            never: :stub }.freeze

        private

        # course of action based on config/status/options
        # @return [Symbol] :yield, :cache_yield, or
        def cache_action
          log_cache_action do
            send "#{cache_status}_cache_action"
          end
        end

        def log_cache_action
          yield.tap do |action|
            Rails.logger.warn "VIEW CACHE #{cache_active? ? '-->' : ''}[#{action}] "\
                                "(#{card.name}##{requested_view})"
          end
        end

        # @return [Symbol] :off, :active, or :free
        def cache_status
          case
          when !cache_on?
            :off      # view caching is turned off, format- or system-wide
          when cache_active?
            :active   # another view cache is in progress (current view is inside it)
          else
            :free     # no other cache in progress
          end
        end

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # CACHE STATUS: FREE
        # caching is on; no other cache in progress

        # @return [Symbol]
        def free_cache_action
          free_cache_ok? ? :cache_yield : :yield
        end

        # @return [True/False]
        def free_cache_ok?
          !cache_setting.in?(%i[default never]) && clean_enough_to_cache?
        end

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # CACHE STATUS: ACTIVE
        # another view cache is in progress; this view is inside it

        # @return [Symbol]
        def active_cache_action
          if caching == :force
            :yield
          elsif deep_caching? && cache_setting != :never
            :yield
          elsif active_cache_ok?
            active_cache_action_from_setting
          else
            :stub
          end
        end

        # @return [True/False]
        def active_cache_ok?
          return false unless cacheable_card? && clean_enough_to_cache?
          return true if normalized_options[:skip_perms]

          active_cache_permissible?
        end

        def cacheable_card?
          return true if deep_caching? || parent.present?
          # a parent voo means we're still in the same card

          return false unless (superformat_card = format.parent&.card)

          superformat_card.name == card.name.left_name
        end

        # apply any permission checks required by view.
        # (do not cache views with nuanced permissions)
        def active_cache_permissible?
          case view_perms
          when :none             then true
          when view_perm_context then true
          when *Permission::CRUD then format.anyone_can?(view_perms)
          else                        false
          end
        end

        def view_perm_context
          parent&.view_perms || format.parent&.voo&.view_perms
        end

        # determine the cache action from the cache setting
        # (assuming cache status is "active")
        # @return [Symbol] cache action
        def active_cache_action_from_setting
          level = ACTIVE_CACHE_LEVEL[cache_setting]
          level || raise("unknown cache setting: #{cache_setting}")
        end

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # SHARED METHODS
        def deep_caching?
          caching.in? %i[deep force]
        end

        # @return [Symbol] :default, :yes, :deep, :force, :always, or :never
        def cache_setting
          @cache_setting ||= format.view_cache_setting requested_view
        end

        # altered view requests and altered cards are not cacheable
        # @return [True/False]
        def clean_enough_to_cache?
          #  requested_view == ok_view && !card.unknown? && !card.db_content_changed?
          requested_view == ok_view && card.view_cache_clean?
        end
      end
    end
  end
end
