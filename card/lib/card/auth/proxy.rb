class Card
  module Auth
    # mechanism for assuming permissions of another user.
    module Proxy
      # operate with the permissions of another "proxy" user
      def as given_user
        tmp_id = @as_id
        tmp_card = @as_card

        @as_id = Card.id given_user
        @as_card = nil
        # we could go ahead and set as_card if given a card...

        @current_id = @as_id if @current_id.nil?

        return unless block_given?

        yield
      ensure
        if block_given?
          @as_id = tmp_id
          @as_card = tmp_card
        end
      end

      # operate with the permissions of DeckoBot (administrator)
      def as_bot &block
        as Card::DeckoBotID, &block
      end

      # id of proxy user
      # @return [Integer]
      def as_id
        @as_id || current_id
      end

      # proxy user card
      # @return [Card]
      def as_card
        return @as_card if @as_card&.id == as_id

        @as_card = Card[as_id]
      end

      # @param auth_data [Integer|Hash] user id, user name, or a hash
      # @option auth_data [Integer] current_id
      # @option auth_data [Integer] as_id
      def with auth_data
        if auth_data.is_a?(Integer) || auth_data.is_a?(String)
          auth_data = { current_id: Card.id(auth_data) }
        end

        temporarily do
          # resets @as and @as_card
          self.current_id = auth_data[:current_id]
          @as_id = auth_data[:as_id] if auth_data[:as_id]
          yield
        end
      end

      private

      def temporarily
        tmp_current_id = current_id
        tmp_as_id = as_id
        tmp_current_card = @current_card
        tmp_as_card = @as_card
        tmp_current_roles = @current_roles
        yield
      ensure
        @current_id = tmp_current_id
        @as_id = tmp_as_id
        @current = tmp_current_card
        @as_card = tmp_as_card
        @current_roles = tmp_current_roles
      end
    end
  end
end
