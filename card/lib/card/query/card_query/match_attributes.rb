class Card
  module Query
    class CardQuery
      # handle special CQL attributes
      module MatchAttributes
        def found_by val
          found_by_cards(val).compact.each do |card|
            subquery found_by_statement(card).merge(fasten: :direct, context: card.name)
          end
        end

        # Implements the match attribute that matches always against content and name.
        # Currently that's different from the match operator that can be restricted to
        # names or content.
        # Example: { match: "name or content" } vs. { name: ["match", "a name"] }
        # TODO: unify handling for both using full text indexing
        def match val
          val.gsub!(/[^#{Card::Name::OK4KEY_RE}]+/, " ")
          return nil if val.strip.empty?
          val.gsub!("*", '\\\\\\\\*')
          val_list = val.split(/\s+/).map do |v|
            name_or_content_match v
          end
          add_condition and_join(val_list)
        end

        def complete val
          add_condition name_like("#{val.to_name.key}%", val =~ /\+/)
        end

        private

        def name_or_content_match val
          cxn = connection
          or_join([name_match(val), content_match(val, cxn)])
        end

        def name_match val
          name_like "%#{val.to_name.key}%", true
        end

        def content_match val, cxn
          field_match "#{table_alias}.db_content", val, cxn
        end

        def field_match field, val, cxn
          %(#{field} #{cxn.match quote("[[:<:]]#{val}[[:>:]]")})
        end

        # TODO: move sql to SqlStatement
        def name_like pattern, no_junction
          conds = ["#{table_alias}.key LIKE #{quote pattern}"]
          conds << "#{table_alias}.right_id is null" if no_junction
          # FIXME: -- this should really be more nuanced --
          # it includes all descendants after one plus
          res = conds.join " AND "
          puts res
          res
        end
      end
    end
  end
end
