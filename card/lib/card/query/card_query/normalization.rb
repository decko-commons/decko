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
            # when return values are relative, they are relative to the name of the
            # card returned, not the context card
            clause[key] = normalize_value val
          end
          clause
        end

        def clause_to_hash clause
          case clause
          when Hash              then clause
          when Integer           then { id: clause }
          when String            then { id: (Card::Lexicon.id(clause) || -2) }
          when Symbol            then { id: Card::Codename.id(clause) }
          else raise Error::BadQuery, "Invalid clause: #{clause.inspect}"
          end
        end

        def normalize_value val
          case val
          when Integer, Float, Hash, Symbol, NilClass then val
          when String                                 then normalize_string_value val
          when Array                                  then normalize_array_value val
          else raise Error::BadQuery, "Invalid value type: #{val.class} (#{val.inspect})"
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
