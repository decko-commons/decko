class Card
  module Query
    class CardQuery
      # conjoining conditions
      module Conjunctions
        def all val
          conjoin val, :and
        end
        alias_method :and, :all

        def any val
          conjoin val, :or
        end
        alias_method :or, :any
        alias_method :in, :any

        def not val
          tie :card, val, { id: :id }, negate: true
        end

        def current_conjunction
          @mods[:conj].blank? ? :and : @mods[:conj]
        end

        private

        def conjunction val
          return unless [String, Symbol].member? val.class

          CONJUNCTIONS[val.to_sym]
        end

        def conjoin val, conj
          subquery = subquery fasten: :direct, conj: conj
          conjoinable_val(val).each do |val_item|
            subquery.interpret val_item
          end
        end

        def conjoinable_val val
          return val if val.is_a? Array

          clause_to_hash(val).map { |key, value| { key => value } }
        end
      end
    end
  end
end
