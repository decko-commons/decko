class Card
  module Query
    class CardQuery
      # Implements the match attributes that match always against content and/or name.
      # Currently that's different from the match operator that can be restricted to
      # names or content.
      # Example: { match: "name or content" } vs. { name: ["match", "a name"] }
      # TODO: unify handling for both using full text indexing
      module MatchAttributes
        # match term anywhere in name or content
        def match val
          val.gsub!(/[^#{Card::Name::OK4KEY_RE}]+/, " ")
          return nil if val.strip.empty?
          val.gsub!("*", '\\\\\\\\*')
          val_list = val.split(/\s+/).map do |v|
            name_or_content_match v
          end
          add_condition and_join(val_list)
        end

        # match names beginning with term
        def complete val
          add_condition key_like("#{val.to_name.key}%", val =~ /\+/)
        end

        # match term anywhere in name
        # DEPRECATE - move handling to name: ["match", val]
        def name_match val
          add_condition name_like(val)
        end

        private

        def name_or_content_match val
          cxn = connection
          or_join([name_like(val), content_match(val, cxn)])
        end

        def name_like val
          key_like "%#{val.to_name.key}%"
        end

        def content_match val, cxn
          field_match "#{table_alias}.db_content", val, cxn
        end

        def field_match field, val, cxn
          %(#{field} #{cxn.match quote("[[:<:]]#{val}[[:>:]]")})
        end

        # TODO: move sql to SqlStatement
        def key_like pattern, no_junction=false
          conds = ["#{table_alias}.key LIKE #{quote pattern}"]
          conds << "#{table_alias}.right_id is null" if no_junction
          # FIXME: -- this should really be more nuanced --
          # it includes all descendants after one plus
          conds.join " AND "
        end

        # TODO: use standard conjunction handling

        def or_join conditions
          "(#{Array(conditions).join ' OR '})"
        end

        def and_join conditions
          "(#{Array(conditions).join ' AND '})"
        end
      end
    end
  end
end
