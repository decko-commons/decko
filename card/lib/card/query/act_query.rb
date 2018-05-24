class Card
  module Query
    # support CQL queries that require the card_acts table
    class ActQuery < AbstractQuery
      def table
        "card_acts"
      end

      def table_prefix
        "cx"
      end

      def action_on card
        tie :action, { action_on: card }, to: :card_act_id
      end

      def update_action_on card
        tie :action, { update_action_on: card }, to: :card_act_id
      end

      def act_by card
        tie :card, card, from: :actor_id
      end
    end
  end
end
