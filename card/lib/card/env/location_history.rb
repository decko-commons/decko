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
        return unless save_location? card

        location = request ? request.original_url : location_for_history(card)
        location_history.push(location).uniq!
      end

      def previous_location
        location_history&.last
      end

      def discard_locations_for card
        session[:history] = location_history.reject do |l|
          location_cardname(l) == card.name
        end.compact
      end

      # def save_interrupted_action uri
      #   session[:interrupted_action] = uri
      # end

      # def interrupted_action
      #   session.delete :interrupted_action
      # end

      private

      def location_for_history card
        Env::Location.card_path card.name.url_key
      end

      def location_cardname location
        URI.parse(location).path.sub(%r{^/}, "").sub(%r{/.*$}, "")&.cardname
      end

      def save_location? card
        # return false unless Auth.signed_in? || Cardio.config.allow_anonymous_cookies

        !Env.ajax? && Env.html? && card.known? && (card.codename != :signin)
      end
    end
  end
end
