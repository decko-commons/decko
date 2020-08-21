class Card
  module Query
    class SqlStatement
      # transform joins from Card::Query::Join objects to SQL string clause
      module Joins
        def joins query=nil
          query ||= @query
          joins_on_query(query).map do |join|
            join_clause join
          end.flatten.join " "
        end

        def joins_on_query query
          query.direct_subqueries.unshift(query).map(&:joins).flatten
        end

        def join_clause join
          subclause = subjoins join
          table = join_table join
          on = on_clause join
          join_clause_parts(join, table, subclause, on).compact.join " "
        end

        def join_clause_parts join, table, subclause, on
          parts = ["\n#{leading_space}", join.side, "JOIN"]
          if join.left? && subclause.present?
            parts + ["(#{table} #{subclause})", on]
          else
            parts + [table, on, subclause]
          end
        end

        def subjoins join
          return unless join.to.is_a? AbstractQuery

          joins join.to
        end

        def join_table join
          to_table = join.to_table
          to_table = "(#{to_table.sql})" if to_table.is_a? CardQuery
          [to_table, join.to_alias].join " "
        end

        def on_clause join
          on_conditions = join.conditions
          on_conditions.unshift ["#{join.from_alias}.#{join.from_field}",
                                 "#{join.to_alias}.#{join.to_field}"].join(" = ")
          on_conditions += on_card_conditions(join) if join.to.is_a? CardQuery
          on_conditions.reject!(&:blank?)
          "ON #{basic_conditions(on_conditions) * ' AND '}"
        end

        def on_card_conditions join
          to = join.to
          explicit = to.conditions_on_join == join ? explicit_conditions(to) : nil
          [explicit, implicit_conditions(to)].compact
        end
      end
    end
  end
end
