class Card
  # Optimized handling of card "rules" (Set+Setting) and preferences.
  module Rule
    RULE_SQL = %(
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

    # FIXME: "follow" hardcoded above

    READ_RULE_SQL = %(
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

    PREFERENCE_SQL = %(
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

    class << self
      def global_setting name
        Auth.as_bot do
          (card = Card[name]) && !card.db_content.strip.empty? && card.db_content
        end
      end

      def toggle val
        val.to_s.strip == "1"
      end

      def rule_cache
        Card.cache.read("RULES") || populate_rule_caches
      end

      def read_rule_cache
        Card.cache.read("READRULES") || populate_read_rule_cache
      end

      # all users that have a user-specific rule for a given rule key
      def user_ids_cache
        Card.cache.read("USER_IDS") || fresh_rule_cache { @user_ids_hash }
      end

      # all keys of user-specific rules for a given user
      def rule_keys_cache
        Card.cache.read("RULE_KEYS") || fresh_rule_cache { @rule_keys_hash }
      end

      def clear_rule_cache
        write_rule_cache nil
        write_user_ids_cache nil
        write_rule_keys_cache nil
      end

      def clear_preference_cache
        # FIXME: too entwined!
        clear_rule_cache
      end

      def clear_read_rule_cache
        Card.cache.write "READRULES", nil
      end

      def preference_names user_name, setting_code
        Card.search({ right: { codename: setting_code },
                      left: { left: { type_id: SetID },
                              right: user_name },
                      return: :name },
                    "preference cards for user: #{user_name}")
      end

      def all_user_ids_with_rule_for set_card, setting_code
        cache_key = "#{user_cache_key_base set_card}+#{setting_code}"
        user_ids = user_ids_cache[cache_key] || []
        user_ids.include?(AllID) ? all_user_ids : user_ids
      end

      private

      def populate_rule_caches
        @rule_hash = {}
        @user_ids_hash = {}
        @rule_keys_hash = {}

        interpret_simple_rules
        interpret_preferences

        write_user_ids_cache @user_ids_hash
        write_rule_keys_cache @rule_keys_hash
        write_rule_cache @rule_hash
      end

      def populate_read_rule_cache
        hash = rows(READ_RULE_SQL).each_with_object({}) do |row, h|
          party_id = row["party_id"].to_i
          h[party_id] ||= []
          h[party_id] << row["read_rule_id"].to_i
        end
        Card.cache.write "READRULES", hash
      end

      def rule_cache_key row
        return false unless (setting_code = Card::Codename[row["setting_id"].to_i])

        anchor_id = row["anchor_id"]
        set_class_id = anchor_id.nil? ? row["set_id"] : row["set_tag_id"]
        return false unless (set_class_code = Card::Codename[set_class_id.to_i])

        [anchor_id, set_class_code, setting_code].compact.map(&:to_s) * "+"
      end

      def interpret_simple_rules
        rows(RULE_SQL).each do |row|
          next unless (key = rule_cache_key row)
          @rule_hash[key] = row["rule_id"].to_i
        end
      end

      def interpret_preferences
        rows(preference_sql).each do |row|
          next unless (key = rule_cache_key row) && (user_id = row["user_id"])
          add_preference_hash_values key, row["rule_id"].to_i, user_id.to_i
        end
      end

      # User-specific rule use the pattern
      # user+set+setting
      def preference_sql user_id=nil
        PREFERENCE_SQL % user_restriction(user_id)
      end

      def user_restriction user_id
        if user_id
          "users.id = #{user_id}"
        else
          "users.type_id = #{UserID}"
        end
      end

      def rows sql
        Card.connection.select_all sql
      end

      def add_preference_hash_values key, rule_id, user_id
        @rule_hash[preference_key(key, user_id)] = rule_id
        @user_ids_hash[key] ||= []
        @user_ids_hash[key] << user_id
        @rule_keys_hash[user_id] ||= []
        @rule_keys_hash[user_id] << key
      end

      def user_cache_key_base set_card
        if (l = set_card.left) && (r = set_card.right)
          "#{l.id}+#{Card::Codename[r.id]}"
        else
          Card::Codename[set_card.id].to_s
        end
      end

      def preference_key key, user_id
        "#{key}+#{user_id}"
      end

      def fresh_rule_cache
        clear_rule_cache
        rule_cache
        yield
      end

      def all_user_ids
        Card.where(type_id: UserID).pluck :id
      end

      def write_rule_cache hash
        Card.cache.write "RULES", hash
      end

      def write_user_ids_cache hash
        Card.cache.write "USER_IDS", hash
      end

      def write_rule_keys_cache hash
        Card.cache.write "RULE_KEYS", hash
      end
    end
  end
end
