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
          subconds = %i[name content].map do |field|
            Value.new([:match, val], self).to_sql field
          end
          add_condition or_join(subconds)
        end

        # match names beginning with term
        def complete val
          add_condition "#{table_alias}.key LIKE '#{val.to_name.key}%'"
          add_condition "#{table_alias}.right_id is null" unless val.match?(/\+/)
          # FIXME: -- this should really be more nuanced --
          # it includes all descendants after one plus
        end

        # match term anywhere in name
        # DEPRECATE - move handling to name: ["match", val]
        def name_match val
          interpret name: [:match, val]
        end

        private

        def or_join conditions
          "(#{Array(conditions).join ' OR '})"
        end
      end
    end
  end
end
