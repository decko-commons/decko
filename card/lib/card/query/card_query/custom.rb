class Card
  module Query
    class CardQuery
      # for query attributes requiring custom handling
      module Custom
        def compound val
          add_condition "left_id IS #{'NOT' if val} NULL"
        end
      end
    end
  end
end
