class Card
  module Query
    # support CQL queries that require the card_acts table
    class ActionQuery < AbstractQuery
      def table
        "card_actions"
      end

      def table_prefix
        "cn"
      end

      def action_by card
        tie :act, { act_by: card }, from: :card_act_id
      end

      def update_action_by card
        add_update_condition
        action_by card
      end

      def action_on card
        tie :card, card, from: :card_id
      end

      def update_action_on card
        add_update_condition
        action_on card
      end

      def add_update_condition
        add_condition "#{fld :action_type} = 1"
      end
    end
  end
end
