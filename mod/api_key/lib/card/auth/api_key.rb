require "jwt"

class Card
  module Auth
    # methods for setting current account
    module ApiKey
      def signin_with opts={}
        if opts[:token]
          signin_with_token opts[:token]
        elsif opts[:api_key]
          signin_with_api_key opts[:api_key]
        else
          signin_with_session
        end
      end

      # set the current user based on api_key
      def signin_with_api_key api_key
        account = find_account_by_api_key api_key
        unless account&.authenticate_api_key api_key
          raise Card::Error::PermissionDenied, "API key authentication failed"
        end

        signin account.left_id
      end

      # find +\*account card by +\*api card
      # @param api_key [String]
      # @return [+*account card, nil]
      def find_account_by_api_key api_key
        find_account_by :api_key, api_key.strip
      end
    end
  end
end
