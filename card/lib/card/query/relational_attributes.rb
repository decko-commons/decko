class Card
  class Query
    module RelationalAttributes
      def type val
        restrict :type_id, val
      end

      def part val
        right_val = val.is_a?(Integer) ? val : val.clone
        any(left: val, right: right_val)
      end

      def left val
        restrict :left_id, val
      end

      def right val
        restrict :right_id, val
      end

      # action_table_id and action_condition are needed to reuse that method
      # for `updater_of`
      def editor_of val, action_table_id=nil, action_condition=nil
        act_join = acts_join self, :actor_id
        joins << act_join
        # all acts where current query finds actor
        action_table_id ||= table_id true
        join_cards(
          val, from_field: "card_id",
               from: actions_join(act_join, "an#{action_table_id}", "card_act_id",
                                  conditions: action_condition)
        )
        # joins cards updated in those acts
      end

      def acts_join from, to_field, opts={}
        join_args = { from: from, to: ["card_acts", "a#{table_id true}", to_field] }
        Join.new join_args.merge(opts)
      end

      def actions_join from, to_alias, to_field, opts={}
        join_args = { from: from, to: ["card_actions", to_alias, to_field] }
        Join.new join_args.merge(opts)
      end

      # action_table_id and action_condition are needed to reuse that method
      # for `updated_by`
      def edited_by val, action_table_id=nil, action_condition=nil
        action_table_id ||= table_id true
        action_join = actions_join self, "an#{action_table_id}", "card_id",
                                   conditions: action_condition
        joins << action_join
        # joins actions that edited cards found by current query
        join_cards val, from_field: "actor_id",
                        from: acts_join(action_join, :id, from_field: "card_act_id")
        # joins cards via acts of those actions
      end

      # edited but not created
      def updated_by val
        action_table_id = table_id true
        edited_by val, action_table_id, "an#{action_table_id}.action_type = 1"
      end

      # editor but not creator
      def updater_of val
        action_table_id = table_id true
        editor_of val, action_table_id, "an#{action_table_id}.action_type = 1"
      end

      def last_editor_of val
        join_cards val, to_field: "updater_id"
      end

      def last_edited_by val
        restrict :updater_id, val
      end

      def creator_of val
        join_cards val, to_field: "creator_id"
      end

      def created_by val
        restrict :creator_id, val
      end

      def member_of val
        interpret right_plus: [RolesID, refer_to: val]
      end

      def member val
        interpret referred_to_by: { left: val, right: RolesID }
      end

      # ~~~~~~ PLUS RELATIONAL

      def left_plus val
        junction val, :left, :right_id
      end

      def right_plus val
        junction val, :right, :left_id
      end

      def plus val
        any(left_plus: val, right_plus: val.deep_clone)
      end

      def junction val, side, to_field
        part_clause, junction_clause = val.is_a?(Array) ? val : [val, {}]
        junction_val = clause_to_hash(junction_clause).merge side => part_clause
        join_cards junction_val, to_field: to_field
      end
    end
  end
end
