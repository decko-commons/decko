class Card
  module Rule
    module Cache
      cattr_reader :sql, :cached_hash_key

      @sql = %(
        SELECT
          rules.id      AS rule_id,
          settings.id   AS setting_id,
          sets.id       AS set_id,
          sets.left_id  AS anchor_id,
          sets.right_id AS set_tag_id
        FROM cards rules
        JOIN cards sets     ON rules.left_id  = sets.id
        JOIN cards settings ON rules.right_id = settings.id
        WHERE     sets.type_id = #{SetID}
          AND settings.type_id = #{SettingID}
          AND (settings.codename != 'follow' OR rules.db_content != '')
          AND    rules.trash is false
          AND     sets.trash is false
          AND settings.trash is false;
      ).freeze

      @cached_hash_key = "RULES"

      def read
        Card.cache.read(@cached_hash_key) || populate_cache
      end

      def write
        Card.cache.write @cached_hash_key, @hash
      end

      def interpret
        rows(@sql).each do |row|
          next unless (key = lookup_key row)
          @hash[key] = row["rule_id"].to_i
        end
      end

      def lookup_key row
        return false unless (setting_code = setting_code(row)) &&
                            (anchor_id = row["anchor_id"]) &&
                            (pattern_code = pattern_code(anchor_id, row))

        [anchor_id, pattern_code, setting_code].compact.map(&:to_s).join "+"
      end

      def pattern_code anchor_id, row
        set_class_id = anchor_id.nil? ? row["set_id"] : row["set_tag_id"]
        Card::Codename[set_class_id.to_i]
      end

      def setting_code row
        Card::Codename[row["setting_id"].to_i]
      end

      def rows sql
        Card.connection.select_all sql
      end
    end
  end
end
