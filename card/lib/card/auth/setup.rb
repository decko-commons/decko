class Card
  module Auth
    # singleton methods for managing setup state
    module Setup
      @simulating_setup_need = nil
      SETUP_COMPLETED_KEY = "SETUP_COMPLETED".freeze

      # app is not totally set up yet
      # @return [true/false]
      def needs_setup?
        # FIXME: - should not require a cache lookup with every request!!
        @simulating_setup_need || (
          !Card.cache.read(SETUP_COMPLETED_KEY) &&
          !Card.cache.write(SETUP_COMPLETED_KEY, user_account_count.positive?)
        )
        # every deck starts with two accounts: WagnBot and Anonymous
      end

      # act as if site is not set up
      # @param mode [true/false] simulate setup need if true
      def simulate_setup_need! mode=true
        @simulating_setup_need = mode
      end

      # for testing setup
      def hide_accounts! mode=true
        Card.cache.delete(SETUP_COMPLETED_KEY) if mode
        @hidden_accounts = mode && user_account_ids
      end

      def instant_account_activation
        simulate_setup_need!
        yield
      ensure
        simulate_setup_need! false
      end

      private

      def user_account_ids
        as_bot { Card.search user_account_cql.merge(return: :id) }
      end

      def user_account_cql
        { right_id: Card::AccountID, creator_id: ["ne", Card::WagnBotID] }
      end

      def user_account_count
        cql = user_account_cql
        cql[:not] = { id: ["in"].concat(@hidden_accounts) } if @hidden_accounts
        as_bot { Card.count_by_cql cql }
      end
    end
  end
end
