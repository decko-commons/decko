class Card
  # Card::Env is a module for containing the variable details of the environment
  # in which Card operates.
  #
  # Env can differ for each request; Card.config should not.
  module Env
    extend LocationHistory
    extend SlotOptions
    extend Serialization

    class << self
      attr_accessor :controller, :main_name, :params

      # TODO: upgrade to lazy loading
      def reset controller=nil
        @controller = controller
        @params = controller&.params || {}
        @main_name = @session = nil
      end

      def request
        controller&.request
      end

      def session
        @session ||= request&.session || {}
      end

      def ip
        request&.remote_ip
      end

      def ajax?
        request&.xhr? || params[:simulate_xhr]
      end

      def html?
        !controller || params[:format]&.in?([nil, "html"])
      end

      def host
        request&.host
      end

      def origin
        Cardio.config.deck_origin || "#{protocol}#{request&.host_with_port}"
      end

      def protocol
        request&.protocl
      end

      def with_params hash
        old_params = params.clone
        params.merge! hash
        yield
      ensure
        @params = old_params
      end

      def hash hashish
        case hashish
        when Hash then hashish.clone
        when ActionController::Parameters then hashish.to_unsafe_h
        else {}
        end
      end

      def reset_session
        if session.is_a? Hash
          @session = {}
        else
          controller&.reset_session
        end
      end

      def success cardname=nil
        @success ||= Env::Success.new(cardname, params[:success])
      end

      def localhost?
        host&.match?(/^localhost/)
      end
    end
  end
end

Card::Env.reset
