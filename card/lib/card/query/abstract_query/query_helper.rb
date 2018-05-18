class Card
  module Query
    class AbstractQuery
      # shared methods for queries
      module QueryHelper
        def direct_subqueries
          direct = subqueries.select { |s| s.fasten == :direct }
          direct + direct.map(&:direct_subqueries).flatten
        end

        def table_alias
          @table_alias ||= begin
            if fasten == :direct
              @superquery.table_alias
            else
              "#{table_prefix}#{table_id}"
            end
          end
        end

        # generates an id used to identify a table variable in the sql statement
        def table_id force=false
          if force
            tick_table_seq!
          else
            @table_id ||= tick_table_seq!
          end
        end

        def tick_table_seq!
          root.table_seq = root.table_seq.to_i + 1
        end

        def fld field_name
          "#{table_alias}.#{field_name}"
        end

        def exists subquery_type, val, where, subquery_args={}
          s = subquery exists_subquery_args(subquery_args, subquery_type)
          s.interpret val
          s.exists_where where if where
          s
        end

        def exists_subquery_args args, type
          args.reverse_merge! fasten: :exist
          unless type == :card
            args[:class] = Card::Query.const_get("#{type.capitalize}Query")
          end
          args
        end

        def exists_where hash
          hash.each { |k, v| superfield k, v }
        end

        def superfield myfield, superfield
          add_condition "#{fld myfield} = #{superquery.fld superfield}"
        end

        def restrict id_field, val
          if (id = id_from_val(val))
            interpret id_field => id
          else
            exists :card, val, id: id_field
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
