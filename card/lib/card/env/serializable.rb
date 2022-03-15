class Card
  module Env
    # These methods are all handled in serialization and are thus preserved for the
    # integrate_with_delay phase
    module Serializable
      attr_reader :main_name, :params

      def ip
        request&.remote_ip
      end

      def protocol
        request&.protocol
      end

      def host
        request&.host
      end

      def origin
        Cardio.config.deck_origin || "#{protocol}#{request&.host_with_port}"
      end

      def ajax
        request&.xhr? || params[:simulate_xhr]
      end
      alias_method :ajax?, :ajax

      def html
        !controller || params[:format].in?([nil, "html"])
      end
      alias_method :html?, :html
    end
  end
end
