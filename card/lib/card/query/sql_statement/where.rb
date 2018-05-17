
class Card
  class Query
    class SqlStatement
      # handle where clause in SqlStatement
      module Where

        def where
          conditions = [explicit_conditions(@query), implicit_conditions(@query)]
          conditions = conditions.reject(&:blank?).join "\nAND "
          "WHERE #{conditions}" unless conditions.blank?
        end

        # conditions explicitly specified in the query object
        def explicit_conditions query
          cond_list = basic_conditions query.conditions
          cond_list += conditions_from query.subqueries
          cond_list.reject!(&:blank?)
          format_conditions cond_list, query
        end

        def conditions_from subqueries
          subqueries.map do |subquery|
            next if subquery.conditions_on_join
            explicit_conditions subquery
          end
        end

        def basic_conditions conditions
          conditions.map do |condition|
            if condition.is_a? String
              condition
            else
              field, val = condition
              val.to_sql field
            end
          end
        end

        # handle trash and permissions
        def implicit_conditions query
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
          "\n#{query.current_conjunction.upcase} "
        end
      end
    end
  end
end
