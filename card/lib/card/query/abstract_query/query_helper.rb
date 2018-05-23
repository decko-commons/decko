class Card
  module Query
    class AbstractQuery
      # shared methods for queries
      module QueryHelper
        def direct_subqueries
          direct = subqueries.select { |s| s.fasten == :direct }
          direct + direct.map(&:direct_subqueries).flatten
        end

        def join_subqueries
          heirs = subqueries.select { |s| [:direct, :join].include? s.fasten }
          heirs + heirs.map(&:join_subqueries).flatten.uniq
        end

        def table_alias
          @table_alias ||= begin
            if fasten == :direct
              @superquery.table_alias
            else
              "#{table_prefix}#{depth}#{table_suffix}"
            end
          end
        end

        def table_suffix
          return if root?
          map ||= root.table_suffix_map
          map[depth] = map[depth] ? (map[depth] + 1) : 0
          "_#{map[depth]}"
        end

        def table_suffix_map
          @table_suffix_map ||= {}
        end

        def fld field_name
          "#{table_alias}.#{field_name}"
        end

        def tie subquery_type, val, conditions, subquery_args={}
          subquery_args[:fasten] ||= :join
          subquery_args[:class] = Query.class_for subquery_type
          interpret_tie subquery(subquery_args), val, conditions
        end

        def interpret_tie subquery, val, conditions
          subquery.interpret val
          case subquery.fasten
          when :exist, :not_exist
            subquery.super_conditions conditions if conditions
          when :join
            join_on subquery, conditions
          end
          subquery
        end

        def super_conditions hash
          hash.each { |k, v| superfield k, v }
        end

        def join_on subquery, conditions
          join_args = { from: self, to: subquery }
          if conditions
            to_field = join_args[:to_field] = conditions.keys.first
            join_args[:from_field] = conditions[to_field]
          end
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
            tie :card, val, id: id_field
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
