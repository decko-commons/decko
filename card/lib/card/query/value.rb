class Card
  module Query
    # handling for CQL value clauses, eg [operator, value]
    class Value
      include Clause
      include MatchValue

      SQL_FIELD = { name: "key", content: "db_content" }.freeze

      attr_reader :query, :operator, :value

      def initialize rawvalue, query
        @query = query
        @operator, @value = parse_value rawvalue
        canonicalize_operator
      end

      def to_sql field
        if @operator == "~"
          match_sql field
        else
          standard_sql field
        end
      end

      private

      def standard_sql field
        @value = Array.wrap(@value).map { |v| v.to_name.key } if field.to_sym == :name
        "#{field_sql field} #{@operator} #{sqlize @value}"
      end

      def parse_value value
        case value
        when Array           then parse_array_value value.clone
        when nil             then ["is", nil]
        else                      ["=", parse_simple_value(value)]
        end
      end

      def parse_array_value array
        operator = operator?(array.first) ? array.shift : :in
        [operator, array.flatten.map { |i| parse_simple_value i }]
      end

      def parse_simple_value value
        case value
        when String, Integer then value
        when Symbol          then value.to_s
        when nil             then nil
        else raise Error::BadQuery, "Invalid property value: #{value.inspect}"
        end
      end

      def canonicalize_operator
        unless (target = OPERATORS[@operator.to_s])
          raise Error::BadQuery, "Invalid operator: #{@operator}"
        end

        @operator = target
      end

      def operator? key
        OPERATORS.key? key.to_s
      end

      def sqlize v
        case v
        when Query then v.to_sql
        when Array then sqlize_array v
        when nil   then "NULL"
        else quote(v.to_s)
        end
      end

      def sqlize_array array
        array.flatten!
        if array.size == 1 && !@operator.in?(["in", "not in"])
          sqlize array.first
        else
          "(#{array.map { |x| sqlize(x) }.join(',')})"
        end
      end

      def field_sql field
        "#{@query.table_alias}.#{standardize_field field}"
      end

      def standardize_field field
        SQL_FIELD[field.to_sym] || safe_sql(field.to_s)
      end
    end
  end
end
