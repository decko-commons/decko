class Card
  module Env
    module Standard
      def request
        controller&.request
      end

      def session
        @session ||= request&.session || {}
      end

      def ip
        request&.remote_ip
      end

      def ajax
        request&.xhr? || params[:simulate_xhr]
      end
      alias_method :ajax?, :ajax

      def html
        !controller || params[:format]&.in?([nil, "html"])
      end
      alias_method :html?, :html

      def host
        request&.host
      end

      def origin
        Cardio.config.deck_origin || "#{protocol}#{request&.host_with_port}"
      end

      def protocol
        request&.protocol
      end
    end
  end
end
