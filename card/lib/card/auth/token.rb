require "jwt"

class Card
  module Auth
    # methods for setting current account
    module Token
      SECRET_KEY = Rails.application.secrets.secret_key_base.to_s

      class << self
        def encode user_id, extra_payload={}
          payload = { user_id: user_id, exp: expiration }.merge(extra_payload)

          JWT.encode payload, SECRET_KEY
        end

        # returns Hash if valid, String error message if not

        def validate! token
          payload = decode token
          raise Card::Error::PermissionDenied, payload if payload.is_a? String

          payload
        end

        def decode token
          decoded = JWT.decode(token, SECRET_KEY)[0]
          HashWithIndifferentAccess.new decoded
        rescue StandardError => e
          e.message
        end

        def expiration
          Card.config.token_expiry.from_now.to_i
        end
      end

      # set the current user based on token
      def signin_with_token token
        payload = Token.validate! token
        signin payload[:anonymous] ? Card::AnonymousID : payload[:user_id]
      end
    end
  end
end
