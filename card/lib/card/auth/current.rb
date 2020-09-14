class Card
  module Auth
    # methods for setting current account
    module Current
      # set current user in process and session
      def signin cardish
        signin_id = Card.id(cardish) || Card::AnonymousID
        self.current_id = signin_id
        set_session_user signin_id
      end

      # current user is not anonymous
      # @return [true/false]
      def signed_in?
        current_id != Card::AnonymousID
      end

      # id of current user card.
      # @return [Integer]
      def current_id
        @current_id ||= Card::AnonymousID
      end

      # current accounted card (must have +\*account)
      # @return [Card]
      def current
        if @current && @current.id == current_id
          @current
        else
          @current = Card[current_id]
        end
      end

      def current_roles
        @current_roles ||= [Card.fetch_name(:anyone_signed_in),
                            current.fetch(:roles)&.item_names].flatten.compact
      end

      def serialize
        { as_id: as_id, current_id: current_id }
      end

      # @param auth_data [Integer|Hash] user id, user name, or a hash
      # @option auth_data [Integer] current_id
      # @option auth_data [Integer] as_id
      def with auth_data
        if auth_data.is_a?(Integer) || auth_data.is_a?(String)
          auth_data = { current_id: Card.id(auth_data) }
        end

        tmp_current_id = current_id
        tmp_as_id = as_id
        tmp_current = @current
        tmp_as_card = @as_card
        tmp_current_roles = @current_roles

        # resets @as and @as_card
        self.current_id = auth_data[:current_id]
        @as_id = auth_data[:as_id] if auth_data[:as_id]
        yield
      ensure
        @current_id = tmp_current_id
        @as_id = tmp_as_id
        @current = tmp_current
        @as_card = tmp_as_card
        @current_roles = tmp_current_roles
      end

      # get session object from Env
      # return [Session]
      def session
        Card::Env.session
      end

      # set current from token, api_key, or session
      def signin_with opts={}
        if opts[:token]
          signin_with_token opts[:token]
        elsif opts[:api_key]
          signin_with_api_key opts[:api_key]
        else
          signin_with_session
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

      # get :user id from session and set Auth.current_id
      def signin_with_session
        card_id = session_user
        signin(card_id && Card.exists?(card_id) ? card_id : nil)
      end

      # find +\*account card by +\*api card
      # @param api_key [String]
      # @return [+*account card, nil]
      def find_account_by_api_key api_key
        find_account_by :api_key, api_key.strip
      end

      # find +\*account card by +\*email card
      # @param email [String]
      # @return [+*account card, nil]
      def find_account_by_email email
        find_account_by :email, email.strip.downcase
      end

      # general pattern for finding +\*account card based on field cards
      # @param fieldcode [Symbol] code of account field
      # @param value [String] content of field
      # @return [+*account card, nil]
      def find_account_by fieldcode, value
        Auth.as_bot do
          Card.search({ right_id: Card::AccountID,
                        right_plus: [Card::Codename.id(fieldcode), { content: value }] },
                      "find +:account with +#{fieldcode} (#{value})").first
        end
      end

      def session_user
        session[session_user_key]
      end

      def set_session_user card_id
        session[session_user_key] = card_id
      end

      def session_user_key
        "user_#{database.underscore}".to_sym
      end

      def database
        Rails.configuration.database_configuration.dig Rails.env, "database"
      end

      # set the id of the current user.
      def current_id= card_id
        @current = @as_id = @as_card = @current_roles = nil
        card_id = card_id.to_i if card_id.present?
        @current_id = card_id
      end
    end
  end
end
