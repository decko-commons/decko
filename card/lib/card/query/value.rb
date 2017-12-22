class Card
  class Query
    class Value
      include Clause
      SQL_FIELD = { name: "key", content: "db_content" }.freeze

      attr_reader :query, :operator, :value

      def initialize rawvalue, query
        @query = query
        @operator, @value = parse_value rawvalue
        canonicalize_operator
      end

      def parse_value rawvalue
        case rawvalue
        when String, Integer then ["=", rawvalue]
        when Array           then parse_array_value rawvalue
        else raise("Invalid Condition Clause #{rawvalue}.inspect}")
        end
      end

      def parse_array_value array
        operator = operator?(array.first) ? array.shift : :in
        [operator, array]
      end

      def canonicalize_operator
        unless (target = OPERATORS[@operator.to_s])
          raise Card::Error::BadQuery, "Invalid Operator #{@operator}"
        end
        @operator = target
      end

      def operator? key
        OPERATORS.key? key.to_s
      end

      def sqlize v
        case v
        when Query then  v.to_sql
        when Array then  "(" + v.flatten.map { |x| sqlize(x) }.join(",") + ")"
        else quote(v.to_s)
        end
      end

      def to_sql field
        value = value_sql field, @value
        "#{field_sql field} #{operational_sql value}"
      end

      def operational_sql value
        if @operator == "~"
          connection.match value
        else
          "#{@operator} #{value}"
        end
      end

      def field_sql field
        db_field = SQL_FIELD[field.to_sym] || safe_sql(field.to_s)
        "#{@query.table_alias}.#{db_field}"
      end

      def value_sql field, value
        value = [value].flatten.map(&:to_name).map(&:key) if field.to_sym == :name
        sqlize value
      end
    end
  end
end
