class Card
  class Query
    class CardQuery
      module Conjunctions
        def all val
          conjoin val, :and
        end
        alias and all

        def any val
          conjoin val, :or
        end
        alias or any
        alias in any

        def conjoin val, conj
          sq = subquery fasten: :direct, conj: conj
          unless val.is_a? Array
            val = clause_to_hash(val).map { |key, value| { key => value } }
          end
          val.each do |val_item|
            sq.interpret val_item
          end
        end

        def not val
          subquery = exists_card val, id: :id
          subquery.fasten = :not_exist
        end

        def conjunction val
          return unless [String, Symbol].member? val.class
          CONJUNCTIONS[val.to_sym]
        end
      end
    end
  end
end
