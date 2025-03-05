# -*- encoding : utf-8 -*-

class Card
  # Singleton methods for account authentication and contextualization.
  #
  # Manages current user,
  # "as" user, and password verification.
  module Auth
    extend Permissions
    extend Proxy
    extend Setup
    extend Current
    extend Token

    class << self
      # authenticate a user by their login name and unencrypted password.
      # @param email [String]
      # @param password [String]
      # @return [+*account card, nil]
      def authenticate email, password
        account = Auth.find_account_by_email email
        return nil unless account&.active?

        account if not_required? || password_valid?(account, password.strip)
      end

      # check whether password is correct for account card
      # @param account [+*account card]
      # @param password [String]
      def password_valid? account, password
        account.password == encrypt(password, account.salt)
      end

      # encrypt password string with the given salt.
      # @return [SHA1 String]
      def encrypt password, salt
        Digest::SHA1.hexdigest "#{salt}--#{password}--"
      end

      def serialize
        { as_id: as_id, current_id: current_id }
      end

      def not_required?
        Card.config.no_authentication
      end
    end
  end
end
