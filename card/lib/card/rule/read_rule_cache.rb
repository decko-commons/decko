class Card
  module Rule
    # the read rule cache, unlike the standard rule cache, is optimized for lookups
    # based on the rules' values, because this is needed for high-performance
    # permission-checking
    class ReadRuleCache < Cache
      self.sql = %(
        SELECT
          refs.referee_id AS party_id,
          read_rules.id   AS read_rule_id
        FROM cards read_rules
        JOIN card_references refs ON refs.referer_id    = read_rules.id
        JOIN cards sets           ON read_rules.left_id = sets.id
        WHERE read_rules.right_id = #{ReadID}
          AND       sets.type_id  = #{SetID}
          AND read_rules.trash is false
          AND       sets.trash is false;
      ).freeze

      self.cache_key = "READRULES".freeze

      class << self
        private

        def lookup_hash
          rows.each_with_object({}) do |row, h|
            party_id = row["party_id"].to_i
            h[party_id] ||= []
            h[party_id] << row["read_rule_id"].to_i
          end
        end
      end
    end
  end
end
