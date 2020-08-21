class Card
  module Query
    class CardQuery
      # Interpret CQL. Once interpreted, SQL can be generated.
      #
      module Interpretation
        INTERPRET_METHOD = { basic: :add_condition,
                             relational: :relate,
                             plus_relational: :relate_compound,
                             conjunction: :send }.freeze

        # normalize and extract meaning from a clause
        # @param clause [Hash, String, Integer] statement or chunk thereof
        def interpret clause
          normalize_clause(clause).each do |key, val|
            interpret_item key, val
          end
        end

        def interpret_item key, val
          if interpret_as_content? key
            interpret content: [key, val]
          elsif interpret_as_modifier? key, val
            interpret_modifier key, val
          else
            interpret_attributes key, val
          end
        end

        def interpret_as_content? key
          # eg "match" is both operator and attribute;
          # interpret as attribute when "match" is key
          OPERATORS.key?(key.to_s) && !ATTRIBUTES[key]
        end

        def interpret_as_modifier? key, val
          # eg when "sort" is hash, it can have subqueries
          # and must be interpreted like an attribute
          MODIFIERS.key?(key) && !val.is_a?(Hash)
        end

        def interpret_modifier key, val
          @mods[key] = val.is_a?(Array) ? val : val.to_s
        end

        def interpret_attributes key, val
          attribute = ATTRIBUTES[key]
          if (method = INTERPRET_METHOD[attribute])
            send method, key, val
          elsif attribute != :ignore
            bad_attribute! key
          end
        end

        def bad_attribute! attribute
          raise Error::BadQuery, "Invalid attribute: #{attribute}"
        end

        def relate_compound key, val
          has_multiple_values =
            val.is_a?(Array) &&
            (val.first.is_a?(Array) || conjunction(val.first).present?)
          relate key, val, multiple: has_multiple_values
        end

        def relate key, val, opts={}
          multiple = opts[:multiple].nil? ? val.is_a?(Array) : opts[:multiple]
          method = opts[:method] || :send
          if multiple
            relate_multi_value method, key, val
          else
            send method, key, val
          end
        end

        def relate_multi_value method, key, val
          conj = conjunction(val.first) ? conjunction(val.shift) : :and
          if conj == current_conjunction
            # same conjunction as container, no need for subcondition
            val.each { |v| send method, key, v }
          else
            send conj, (val.map { |v| { key => v } })
          end
        end
      end
    end
  end
end
