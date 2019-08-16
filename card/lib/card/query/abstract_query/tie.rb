class Card
  module Query
    class AbstractQuery
      # The "Tie" methods support tying two queries (CardQuery, ReferenceQuery, etc)
      # together.  The "fasten" variable determines which tying strategy is used.
      #
      # We currently support three values for "fasten": :join, :exist, and :in
      #
      # In concept, here's how the different strategies would tie table A to table B
      # in SQL assuming A.id = B.a_id
      #
      # - :join  ...  FROM A JOIN B ON A.id = B.a_id
      # - :exist ...  FROM A WHERE EXISTS (SELECT * FROM B WHERE A.id = B.a_id ...)
      # - :in    ...  FROM A WHERE A.id IN (SELECT B.a_id FROM B WHERE ...)
      #
      # The different strategies will return the same values but the relative speed is
      # context dependent.
      module Tie
        def tie subquery_type, val, fields={}, subquery_args={}
          subquery = tie_subquery subquery_type, subquery_args
          subquery.interpret val
          fields = { from: :id, to: :id }.merge fields
          fasten_tie subquery, fields
        end

        def tie_subquery subquery_type, subquery_args
          subquery_args[:class] = Query.class_for subquery_type
          subquery(subquery_args)
        end

        def fasten_tie subquery, fields={}
          method = "tie_with_#{subquery.fasten}"
          send method, subquery, fields
          subquery
        end

        def tie_with_join subquery, fields={}
          join = Join.new tie_with_join_args(subquery, fields)
          negate_join(subquery, join, fields) if subquery.negate
          joins << join
        end

        def tie_with_in subquery, fields
          subquery.mods[:return] = fields[:to]
          subquery.mods[:in_field] = fld(fields[:from])
        end

        def tie_with_exist subquery, fields
          subquery.super_conditions fields if fields.present?
        end

        def fasten
          @fasten ||= root? ? :join : inherit_fasten
        end

        def tie_with_join_args subquery, fields
          args = { from: self, from_field: fields[:from],
                   to: subquery, to_field: fields[:to] }
          args[:side] = :left if left_join? subquery
          args
        end

        def left_join? subquery
          current_conjunction == "or" || subquery.negate
          # reverse conjunction if negated?
        end

        def negate_join subquery, join, fields
          subquery.conditions_on_join = join
          add_condition "#{subquery.fld fields[:to]} is null"
        end

        def inherit_fasten
          superfasten = superquery.fasten
          superfasten == :direct ? superquery.inherit_fasten : superfasten
        end

        def super_conditions fields
          superfield fields[:to], fields[:from]
        end

        def superfield myfield, superfield
          add_condition "#{fld myfield} = #{superquery.fld superfield}"
        end

        def restrict id_field, val
          if (id = id_from_val(val))
            interpret id_field => id
          else
            tie :card, val, from: id_field
          end
        end

        def id_from_val val
          case val
          when Integer then val
          when String  then Card.fetch_id(val) || -999
          when Symbol  then Card::Codename.id(val) || -999
          end
        end
      end
    end
  end
end
