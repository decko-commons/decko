class Card
  module Query
    class CardQuery
      # normalize clause's keys and values.
      module Normalization
        def normalize_clause clause
          clause = clause_to_hash clause
          clause.symbolize_keys!
          clause.each do |key, val|
            next if key.to_sym == :return
            clause[key] = normalize_value val
          end
          clause
        end

        def clause_to_hash clause
          case clause
          when Hash              then clause
          when String            then { key: clause.to_name.key }
          when Integer           then { id: clause }
          else raise Card::Error::BadQuery, "Invalid query args #{clause.inspect}"
          end
        end

        def normalize_value val
          case val
          when Integer, Float, Symbol, Hash then val
          when String                       then normalize_string_value val
          when Array                        then normalize_array_value val
          else raise Card::Error::BadQuery, "unknown WQL value type: #{val.class}"
          end
        end

        def normalize_array_value val
          val.map { |v| normalize_value v }
        end

        def normalize_string_value val
          case val.to_s
          when /^\$(\w+)$/
            # replace from @vars when value starts with dollar sign
            string_value_from_var Regexp.last_match[1]
          when /\b_/
            # absolutize based on @context when there are words beginning with "_"
            val.to_name.absolute(context)
          else
            val
          end
        end

        def string_value_from_var varname
          @vars[varname.to_sym].to_s.strip
        end
      end
    end
  end
end
