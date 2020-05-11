class Card
  module Rule
    module PreferenceCache
      include Rule::Cache

      @sql = %(
        SELECT
          preferences.id AS rule_id,
          settings.id    AS setting_id,
          sets.id        AS set_id,
          sets.left_id   AS anchor_id,
          sets.right_id  AS set_tag_id,
          users.id       AS user_id
        FROM cards preferences
        JOIN cards user_sets ON preferences.left_id  = user_sets.id
        JOIN cards settings  ON preferences.right_id = settings.id
        JOIN cards users     ON user_sets.right_id   = users.id
        JOIN cards sets      ON user_sets.left_id    = sets.id
        WHERE sets.type_id     = #{SetID}
          AND settings.type_id = #{SettingID}
          AND (%s or users.codename = 'all')
          AND sets.trash        is false
          AND settings.trash    is false
          AND users.trash       is false
          AND user_sets.trash   is false
          AND preferences.trash is false;
      ).freeze

      def interpret
        rows(@sql).each do |row|
          next unless (key = rule_cache_key row) && (user_id = row["user_id"])
          add_preference_hash_values key, row["rule_id"].to_i, user_id.to_i
        end
      end

      def add_preference_hash_values key, rule_id, user_id
        @rule_hash[preference_key(key, user_id)] = rule_id
        @user_ids_hash[key] ||= []
        @user_ids_hash[key] << user_id
        @rule_keys_hash[user_id] ||= []
        @rule_keys_hash[user_id] << key
      end
    end
  end
end
