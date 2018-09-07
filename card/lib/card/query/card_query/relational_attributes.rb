class Card
  module Query
    class CardQuery
      # interpret CQL attributes that relate multiple cards
      # each method below corresponds to a relational CQL term
      #
      # NOTE: methods using "restrict" can  be executed without
      # tying in an additional query if the val in question can be
      # reduced to an id.
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

        def editor_of val
          tie_act :action_on, val
        end

        def updater_of val
          tie_act :update_action_on, val
        end

        def edited_by val
          tie_action :action_by, val
        end

        def updated_by val
          tie_action :update_action_by, val
        end

        def last_editor_of val
          tie :card, val, to: :updater_id
        end

        def last_edited_by val
          restrict :updater_id, val
        end

        def creator_of val
          tie :card, val, to: :creator_id
        end

        def created_by val
          restrict :creator_id, val
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

        def tie_action action, val
          tie :action, { action => val }, to: :card_id
        end

        def tie_act action, val
          tie :act, { action => val }, to: :actor_id
        end

        def junction val, side, field
          tie :card, junction_val(val, side), to: field
        end

        def junction_val val, side
          part_clause, junction_clause = val.is_a?(Array) ? val : [val, {}]
          clause_to_hash(junction_clause).merge side => part_clause
        end
      end
    end
  end
end
