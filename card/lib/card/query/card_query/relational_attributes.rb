class Card
  module Query
    class CardQuery
      module RelationalAttributes
        def refer key, val
          subquery class: ReferenceQuery, fasten: :exist, key => val
        end

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

        def editor_of val
          exists_act :action_on, val
        end

        def updater_of val
          exists_act :update_action_on, val
        end

        def edited_by val
          exists_action :action_by, val
        end

        def updated_by val
          exists_action :update_action_by, val
        end

        def last_editor_of val
          exists :card, val, updater_id: :id
        end

        def last_edited_by val
          restrict :updater_id, val
        end

        def creator_of val
          exists :card, val, creator_id: :id
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

        private

        def exists_action action, val
          exists :action, { action => val }, card_id: :id
        end

        def exists_act action, val
          exists :act, { action => val }, actor_id: :id
        end

        def junction val, side, field
          exists :card, junction_val(val, side), field => :id
        end

        def junction_val val, side
          part_clause, junction_clause = val.is_a?(Array) ? val : [val, {}]
          clause_to_hash(junction_clause).merge side => part_clause
        end
      end
    end
  end
end
