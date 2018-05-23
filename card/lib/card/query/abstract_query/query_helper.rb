class Card
  module Query
    class AbstractQuery
      # shared methods for queries
      module QueryHelper
        def direct_subqueries
          subqueries_with_fasten :direct
        end

        def subqueries_with_fasten fasten
          list = []
          subqueries.each do |s|
            next unless Array.wrap(fasten).include? s.fasten
            list << s
            list += s.subqueries_with_fasten s.fasten
          end
          list
        end

        def table_alias
          @table_alias ||= begin
            if fasten == :direct
              @superquery.table_alias
            else
              "#{table_prefix}#{next_table_suffix}"
            end
          end
        end

        def next_table_suffix
          return root.next_table_suffix unless root?
          @table_suffix = (@table_suffix || -1) + 1
        end

        def fld field_name
          "#{table_alias}.#{field_name}"
        end

        def tie subquery_type, val, conditions, subquery_args={}
          subquery_args[:fasten] ||= :join
          subquery_args[:class] = Query.class_for subquery_type
          interpret_tie subquery(subquery_args), val, conditions
        end

        # these conditions are specifically the tie/join conditions
        def interpret_tie subquery, val, fields={}
          fields = { from: :id, to: :id }.merge fields
          subquery.interpret val
          case subquery.fasten
          when :exist, :not_exist
            subquery.super_conditions fields if fields.present?
          when :in
            tie_with_in subquery, fields
          when :join
            join_on subquery, fields
          end
          subquery
        end

        #def tie_with_in subquery, conditions
#
        #end

        def super_conditions fields
          superfield fields[:from], fields[:to]
        end

        def join_on subquery, fields={}
          join_args = { from: self, from_field: fields[:from],
                        to: subquery, to_field: fields[:to] }
          join_args[:side] = :left if current_conjunction == "or"
          joins << Join.new(join_args)
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
          when String  then Card.fetch_id(val)
          end
        end

        def add_condition *args
          @conditions <<
            if args.size > 1
              [args.shift, Query::Value.new(args.shift, self)]
            else
              args[0]
            end
        end

        def current_conjunction
          "AND"
        end
      end
    end
  end
end
