class Card
  module Query
    class Value
      include Clause
      SQL_FIELD = { name: "key", content: "db_content" }.freeze

      attr_reader :query, :operator, :value

      def initialize rawvalue, query
        @query = query
        @operator, @value = parse_value rawvalue
        canonicalize_operator
      end

      def to_sql field
        "#{field_sql field} #{operational_sql}"
      end

      private

      def parse_value rawvalue
        case rawvalue
        when String, Integer then ["=", rawvalue]
        when Symbol          then ["=", rawvalue.to_s]
        when Array           then parse_array_value rawvalue
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
        else quote(v.to_s)
        end
      end

      def operational_sql
        if @operator == "~"
          connection.match match_value
        else
          "#{@operator} #{sqlize @value}"
        end
      end

      def field_sql field
        "#{@query.table_alias}.#{standardize_field field}"
      end

      def standardize_field field
        return "name" if field.to_sym == :name && @operator == "~"
        SQL_FIELD[field.to_sym] || safe_sql(field.to_s)
      end

      def match_value
        term = Array.wrap(@value).join(" ")
        quote process_match_term(term)
      end

      def process_match_term term
        return term if regexp_syntax? term
        escape_regexp_characters term
      end

      # if search val is prefixed with "~~", it is a MYSQL regexp
      # (and will be passed through)
      #
      # Otherwise, all non-alphanumeric characters are escaped.
      #
      # A "~" prefix is ignored.
      def regexp_syntax? val
        return true if val.gsub!(/^\~\~\s*/, "")
        val.gsub!(/^\~/, "")
        false
      end

      def escape_regexp_characters val
        val.gsub(/(\W)/, '\\\\\1')
      end
    end
  end
end
