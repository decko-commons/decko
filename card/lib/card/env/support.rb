class Card
  module Env
    # utility methods for Card::Env
    module Support
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
    end
  end
end
