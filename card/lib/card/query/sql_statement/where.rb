class Card
  module Query
    class SqlStatement
      # handle where clause in SqlStatement
      module Where
        def where
          conditions = [explicit_conditions(@query), implicit_conditions(@query)]
          conditions = conditions.reject(&:blank?).join " AND "
          "WHERE #{conditions}" unless conditions.blank?
        end

        # conditions explicitly specified in the query object
        def explicit_conditions query
          cond_list = basic_conditions query.conditions
          cond_list += conditions_from query.subqueries
          cond_list.reject!(&:blank?)
          format_conditions cond_list, query
        end

        # depending on how a query is "fastened", its conditions may be rendered
        # along with the superquery's
        def conditions_from subqueries
          subqueries.map do |query|
            next if query.conditions_on_join

            case query.fasten
            when :exist     then exist_condition query
            when :in        then in_condition query
            else                 explicit_conditions query
            end
          end
        end

        def exist_condition query
          "#{maybe_not query}EXISTS (#{spaced_subquery_sql query})"
        end

        def maybe_not query
          query.negate ? "NOT " : ""
        end

        def in_condition query
          field = query.mods[:in_field]
          "#{field} #{maybe_not query}IN (#{spaced_subquery_sql query})"
        end

        def spaced_subquery_sql subquery
          "\n#{subquery.sql}\n#{leading_space}"
        end

        # the conditions stored in the query's @conditions variable
        def basic_conditions conditions
          conditions.map do |condition|
            case condition
            when String    then condition
            when Array     then standard_condition(condition)
            end
          end
        end

        def standard_condition condition
          field, val = condition
          val.to_sql field
        end

        # handle trash and permissions
        # only applies to card queries
        def implicit_conditions query
          return unless query.is_a?(CardQuery)

          table = query.table_alias
          [trash_condition(table), permission_conditions(table)].compact * " AND "
        end

        def trash_condition table
          "#{table}.trash is false"
        end

        def permission_conditions table
          return if Auth.always_ok?

          read_rules = Auth.as_card.read_rules
          read_rule_list = read_rules.present? ? read_rules.join(",") : 1
          "#{table}.read_rule_id IN (#{read_rule_list})"
        end

        # convert list of conditions to string
        def format_conditions cond_list, query
          if cond_list.size > 1
            "(#{cond_list.join condition_joint(query)})"
          else
            cond_list.join
          end
        end

        def condition_joint query
          " #{query.current_conjunction.upcase} "
        end
      end
    end
  end
end
