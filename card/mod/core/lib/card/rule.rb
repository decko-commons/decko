class Card
  # Optimized handling of card "rules" (Set+Setting) and preferences.
  module Rule
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
        Rule::Cache.read
      end

      def preference_cache
        PreferenceCache.read
      end

      def read_rule_cache
        ReadRuleCache.read
      end

      def clear_rule_cache
        Cache.clear
      end

      def clear_preference_cache
        PreferenceCache.clear
      end

      def clear_read_rule_cache
        ReadRuleCache.clear
      end

      def preference_names user_name, setting_code
        Card.search({ right: { codename: setting_code },
                      left: { left: { type_id: SetID },
                              right: user_name },
                      return: :name },
                    "preference cards for user: #{user_name}")
      end

      def all_user_ids_with_rule_for set_card, setting_code
        cache_key = "#{set_card.rule_cache_key_base}+#{setting_code}"
        user_ids = PreferenceCache.user_ids[cache_key] || []
        user_ids.include?(AllID) ? all_user_ids : user_ids
      end

      private

      def all_user_ids
        Card.where(type_id: UserID).pluck :id
      end
    end
  end
end
