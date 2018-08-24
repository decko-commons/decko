class Card
  module Query
    class CardQuery
      # helper methods for relational and special attributes
      module AttributeHelper
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

        def found_by_statement card
          card&.try(:wql_hash) || invalid_found_by_card!(card)
        end

        def invalid_found_by_card! card
          raise Card::Error::BadQuery, '"found_by" value must be valid Search, ' \
                                       "but #{card.name} is a #{card.type_name}"
        end

        def found_by_cards val
          if val.is_a? Hash
            Query.run val
          else
            Array.wrap(val).map do |v|
              Card.fetch v.to_name.absolute(context), new: {}
            end
          end
        end

        # TODO: use standard conjunction handling

        def or_join conditions
          "(#{Array(conditions).join ' OR '})"
        end

        def and_join conditions
          "(#{Array(conditions).join ' AND '})"
        end
      end
    end
  end
end
