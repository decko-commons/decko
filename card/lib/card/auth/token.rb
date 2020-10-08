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
        rescue JWT::DecodeError => error
          error.message
        end

        def expiration
          Cardio.config.token_expiry.from_now.to_i
        end
      end
    end
  end
end
