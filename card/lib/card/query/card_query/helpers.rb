class Card
  class Query
    class CardQuery
      module Helpers
        def join_cards val, opts={}
          conditions_on_join = opts.delete :conditions_on_join
          s = subquery
          join_opts = { from: self, to: s }.merge opts
          card_join = Join.new join_opts
          joins << card_join unless opts[:from].is_a? Join
          s.conditions_on_join = card_join if conditions_on_join
          s.interpret val
          s
        end
      end
    end
  end
end
