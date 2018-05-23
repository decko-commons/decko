class Card
  module Query
    class SqlStatement
      # handle transformation of joins from Query representation to SQL
      module Joins
        def joins
          joins_on_query(@query).map do |join|
            join_and_on_clauses join
          end.join " "
        end

        def joins_on_query query
          query.join_subqueries.unshift(query).map(&:joins).flatten
        end

        def join_and_on_clauses join
          ["\n", join_clause(join), "ON", on_clause(join)].join " "
        end

        def join_clause join
          to_table = join.to_table
          to_table = "(#{to_table.sql})" if to_table.is_a? CardQuery
          table_segment = [to_table, join.to_alias].join " "
          [leading_space, join.side, "JOIN", table_segment].compact.join " "
        end

        def on_clause join
          on_conditions = join.conditions
          on_conditions.unshift ["#{join.from_alias}.#{join.from_field}",
                                 "#{join.to_alias}.#{join.to_field}"].join(" = ")
          on_conditions += on_card_conditions(join) if join.to.is_a? CardQuery
          basic_conditions(on_conditions) * " AND "
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
