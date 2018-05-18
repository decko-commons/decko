class Card
  module Query
    class ActionQuery < AbstractQuery
      def table
        "card_actions"
      end

      def table_prefix
        "cn"
      end

      def action_by card
        exists :act, { act_by: card }, id: :card_act_id
      end

      def update_action_by card
        add_update_condition
        action_by card
      end

      def action_on card
        exists :card, card, id: :card_id
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
