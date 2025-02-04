class Card
  module Env
    # session history helpers: we keep a history stack so that in the case of
    # card removal we can crawl back up to the last un-removed location
    module LocationHistory
      def location_history
        session[:history] ||= [Env::Location.card_path("")]
        session[:history].shift if session[:history].size > 5
        session[:history]
      end

      def save_location card
        return unless save_location?(card)

        discard_locations_for card
        location_history.push location_for_history(card)
      end

      def previous_location
        location_history&.last
      end

      def discard_locations_for card
        # quoting necessary because cards have things like "+*" in the names..
        session[:history] = location_history.reject do |loc|
          if (url_key = url_key_for_location(loc))
            url_key.to_name.key == card.key
          end
        end.compact
      end

      def save_interrupted_action uri
        session[:interrupted_action] = uri
      end

      def interrupted_action
        session.delete :interrupted_action
      end


      private

      def location_for_history card
        Env::Location.card_path card.name.url_key
      end

      def url_key_for_location location
        %r{/([^/]*$)} =~ location ? Regexp.last_match[1] : nil
      end

      def save_location? card
        !Env.ajax? && Env.html? && card.known? && (card.codename != :signin)
      end

    end
  end
end
