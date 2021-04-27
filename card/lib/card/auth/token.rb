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

        private

        def expiration
          Card.config.token_expiry.from_now.to_i
        end
      end

      def signin_with opts={}
        if opts[:token]
          signin_with_token opts[:token]
        elsif opts[:api_key]
          signin_with_api_key opts[:api_key]
        else
          super
        end
      end

      # set the current user based on token
      def signin_with_token token
        payload = Token.validate! token
        signin payload[:anonymous] ? Card::AnonymousID : payload[:user_id]
      end

      # set the current user based on api_key
      def signin_with_api_key api_key
        account = find_account_by_api_key api_key
        unless account&.validate_api_key! api_key
          raise Card::Error::PermissionDenied, "API key authentication failed"
        end

        signin account.left_id
      end

      private

      # find +\*account card by +\*api card
      # @param api_key [String]
      # @return [+*account card, nil]
      def find_account_by_api_key api_key
        find_account_by :api_key, api_key.strip
      end
    end
  end
end
