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

      def parse_value rawvalue
        case rawvalue
        when String, Integer then ["=", rawvalue]
        when Symbol          then ["=", rawvalue.to_s]
        when Array           then parse_array_value rawvalue.clone
        when nil             then ["is", nil]
        else raise Error::BadQuery, "Invalid property value: #{rawvalue.inspect}"
        end
      end

      def parse_array_value array
        operator = operator?(array.first) ? array.shift : :in
        [operator, array]
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
        when Array then "(" + v.flatten.map { |x| sqlize(x) }.join(",") + ")"
        when nil   then "NULL"
        else quote(v.to_s)
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
