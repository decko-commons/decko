class Card
  module Query
    class CardQuery
      # nest independent query
      module FoundBy
        def found_by val
          found_by_cards(val).compact.each do |card|
            subquery found_by_subquery(card)
          end
        end

        private

        def found_by_subquery card
          found_by_statement(card).merge(fasten: :direct, context: card.name)
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
            fetch_found_by_cards val
          end
        end

        def fetch_found_by_cards val
          Array.wrap(val).map do |v|
            Card.fetch v.to_name.absolute(context), new: {}
          end
        end
      end
    end
  end
end
