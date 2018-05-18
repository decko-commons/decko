class Card
  module Query
    class SqlStatement
      # handle transformation of joins from Query representation to SQL
      module Joins
        def joins
          join_joins direct_joins
        end

        def direct_joins
          @query.direct_subqueries.unshift(@query).map { &:joins }.flatten
        end

        def join_joins join_list
          clauses = []
          join_list.each do |join|
            clauses << join_on_clause(join)
            clauses << join_joins(deeper_joins(join)) unless join.left?
          end
          clauses.flatten * "\n"
        end

        def join_on_clause join
          [join_clause(join), "ON", on_clause(join)].join " "
        end

        def join_clause join
          to_table = join.to_table
          to_table = "(#{to_table.sql})" if to_table.is_a? Card::Query
          table_segment = [to_table, join.to_alias].join " "

          if join.left? && (djoins = deeper_joins(join)).present?
            table_segment = "(#{table_segment} #{joins djoins})"
          end
          [join.side, "JOIN", table_segment].compact.join " "
        end

        def deeper_joins join
          deeper_joins = join.subjoins
          deeper_joins += join.to.all_joins if join.to.is_a? Card::Query
          deeper_joins
        end

        def on_clause join
          on_conditions = join.conditions
          on_conditions.unshift ["#{join.from_alias}.#{join.from_field}",
                                 "#{join.to_alias}.#{join.to_field}"].join(" = ")
          on_conditions += on_card_conditions(join) if join.to.is_a? Card::Query
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
