class Card
  module Query
    class Value
      class << self
        def match_prefices
          @match_prefices ||= %w[= ~]
        end

        def match_term_and_prefix_re
          @match_term_and_prefix_re ||=
            /^(?<prefix>[#{Regexp.escape match_prefices.join}]*)\s*(?<term>.*)$/
        end
      end

      # handling for match operator
      module MatchValue
        def match_sql field
          exact_name_match(field) ||
            "#{match_field field} #{connection.match match_value}"
        end

        def exact_name_match field
          return false unless match_prefix == "=" && field.to_sym == :name
          "#{field_sql field} = #{quote match_term.to_name.key}"
        end

        def match_field field
          fld = field.to_sym == :name ? "name" : standardize_field(field)
          "#{@query.table_alias}.#{fld}"
        end

        def match_value
          escape_regexp_characters unless match_prefix == "~~"
          quote match_term
        end

        def match_term
          @match_term || (parse_match_term_and_prefix && @match_term)
        end

        def match_prefix
          @match_prefix || (parse_match_term_and_prefix && @match_prefix)
        end

        # if search val is prefixed with "~~", it is a MYSQL regexp
        # (and will be passed through)
        #
        # Otherwise, all non-alphanumeric characters are escaped.
        #
        # A "~" prefix is ignored.

        def parse_match_term_and_prefix
          raw_term = Array.wrap(@value).join(" ")
          matches = raw_term.match self.class.match_term_and_prefix_re
          @match_prefix = matches[:prefix] || ""
          @match_term = matches[:term] || ""
        end

        def escape_regexp_characters
          match_term.gsub!(/(\W)/, '\\\\\1')
        end
      end
    end
  end
end
