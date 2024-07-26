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
          return unless val.present?

          subconds = %i[name content].map do |field|
            Value.new([:match, val], self).to_sql field
          end
          add_condition or_join(subconds)
        end

        # match names beginning with term
        def complete val
          val = val.to_name
          if val.compound?
            interpret left: val.left
            interpret right: { complete: val.right } if val.right.present?
          else
            add_condition "#{table_alias}.key LIKE '#{val.to_name.key}%'" if val.present?
            name_not_null
          end
        end

        # match term anywhere in name
        # DEPRECATE - move handling to name: ["match", val]
        def name_match val
          interpret name: [:match, val] if val.present?
          name_not_null
        end

        private

        def name_not_null
          add_condition "#{table_alias}.key IS NOT NULL"
        end

        def or_join conditions
          "(#{Array(conditions).join ' OR '})"
        end
      end
    end
  end
end
