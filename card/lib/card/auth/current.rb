class Card
  module Auth
    # methods for setting current account
    module Current
      # id of current user card.
      # @return [Integer]
      def current_id
        @current_id ||= Card::AnonymousID
      end

      # set the id of the current user.
      # @return [Integer]
      def current_id= card_id
        reset
        card_id = card_id.to_i if card_id.present?
        @current_id = card_id
      end

      # current accounted card (must have +\*account)
      # @return [Card]
      def current_card
        return @current_card if @current_card&.id == current_id

        @current_card = Card[current_id]
      end
      alias_method :current, :current_card

      def current_roles
        return [] unless signed_in?

        @current_roles ||= [:anyone_signed_in.cardname] +
                           Set::Self::Role.role_ids(current_id).map(&:cardname)
      end

      # set current user in process and session
      def signin cardish
        user_id = Card.id(cardish) || AnonymousID
        (session[session_user_key] = self.current_id = user_id).tap do
          Env.update_cookie_setting !signed_in?
        end
      end

      # current user is not anonymous
      # @return [true/false]
      def signed_in?
        current_id != AnonymousID
      end

      # set current from token, api_key, or session
      def signin_with opts={}
        if opts[:token]
          signin_with_token opts[:token]
        else
          signin_with_session
        end
      end

      # get :user id from session and set Auth.current_id
      def signin_with_session
        card_id = session[session_user_key]
        card_id = nil unless card_id.card&.account?
        signin card_id
      end

      # get session object from Env
      # return [Session]
      def session
        Env.session
      end

      # find +\*account card by +\*email card
      # @param email [String]
      # @return [+*account card, nil]
      def find_account_by_email email
        find_account_by :email, email.strip.downcase
      end

      def reset
        @as_id = @as_card = @current_id = @current_card = @current_roles = nil
      end

      def session_user_key
        "user_#{Cardio.database.underscore}".to_sym
      end

      private

      # general pattern for finding +\*account card based on field cards
      # @param fieldcode [Symbol] code of account field
      # @param value [String] content of field
      # @return [+*account card, nil]
      def find_account_by fieldcode, value
        Auth.as_bot do
          Card.search({ right_id: AccountID,
                        right_plus: [Codename.id(fieldcode), { content: value }] },
                      "find +:account with +#{fieldcode} (#{value})").first
        end
      end
    end
  end
end
