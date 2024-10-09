class Card
  module Rule
    class Cache
      class_attribute :sql, :cache_key

      self.sql = %(
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

      self.cache_key = "RULES".freeze

      class << self
        def read
          Card.cache.read(cache_key) || populate
        end

        def populate
          Card.cache.write cache_key, lookup_hash
        end

        def clear
          Card.cache.write cache_key, nil
        end

        private

        def lookup_hash
          rows.each_with_object({}) do |row, hash|
            next unless (key = lookup_key row)

            hash[key] = row["rule_id"].to_i
          end
        end

        def lookup_key row
          return false unless (setting_code = setting_code(row))

          anchor_id = row["anchor_id"]
          return false unless (pattern_code = pattern_code(anchor_id, row))

          [anchor_id, pattern_code, setting_code].compact.map(&:to_s).join "+"
        end

        def pattern_code anchor_id, row
          set_class_id = anchor_id.nil? ? row["set_id"] : row["set_tag_id"]
          Card::Codename[set_class_id.to_i]
        end

        def setting_code row
          Card::Codename[row["setting_id"].to_i]
        end

        def rows
          Card.connection.select_all sql
        end
      end
    end
  end
end
