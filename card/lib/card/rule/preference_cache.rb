class Card
  module Rule
    # a preference is a user-specific rule.
    # This caches all preferences in the deck
    class PreferenceCache < Cache
      self.sql = %(
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
          AND (users.type_id = #{UserID} or users.codename = 'all')
          AND sets.trash        is false
          AND settings.trash    is false
          AND users.trash       is false
          AND user_sets.trash   is false
          AND preferences.trash is false;
      ).freeze

      self.cache_key = "PREFERENCES".freeze
      USER_ID_CACHE_KEY = "USER_IDS".freeze

      class << self
        def user_ids
          Card.cache.read(USER_ID_CACHE_KEY) || (populate && user_ids)
        end

        def populate
          @rows = nil
          super.tap do
            populate_user_ids
            @rows = nil
          end
        end

        def populate_user_ids
          Card.cache.write USER_ID_CACHE_KEY, user_id_hash
        end

        def user_id_hash
          rows.each_with_object({}) do |row, hash|
            key = lookup_key_without_user row
            hash[key] ||= []
            hash[key] << row["user_id"]
          end
        end

        def clear
          super
          Card.cache.write USER_ID_CACHE_KEY, nil
        end

        def rows
          @rows ||= super
        end

        alias_method :lookup_key_without_user, :lookup_key

        def lookup_key row
          return unless (base = lookup_key_without_user row)

          "#{base}+#{row['user_id']}"
        end
      end
    end
  end
end
