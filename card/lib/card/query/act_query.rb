class Card
  class Query
    class ActQuery < AbstractQuery
      def table
        "card_acts"
      end

      def table_prefix
        "cx"
      end

      def action_on card
        exists :action, { action_on: card }, card_act_id: :id
      end

      def update_action_on card
        exists :action, { update_action_on: card }, card_act_id: :id
      end

      def act_by card
        exists :card, card, id: :actor_id
      end
    end
  end
end
