class Card
  class Query
    module Helpers
      def restrict id_field, val
        if (id = id_from_val(val))
          interpret id_field => id
        else
          join_cards val, from_field: id_field
        end
      end

      def refer key, val
        add_condition subquery(class: Reference, key: key, val: val, fasten: :nested)
      end

      def id_from_val val
        case val
        when Integer then val
        when String  then Card.fetch_id(val)
        end
      end

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
