class Card
  module Rule
    # rule-related Card instance methods
    module All
      def rule setting_code
        rule_card(setting_code, skip_modules: true)&.db_content
      end

      def rule_card setting_code, options={}
        Card.fetch rule_card_id(setting_code), options
      end

      def rule_card_id setting_code
        rule_id_lookup Card::Rule.rule_cache, setting_code
      end

      def preference setting_code, user=nil
        preference_card(setting_code, user, skip_modules: true)&.db_content
      end

      def preference_card setting_code, user=nil, options={}
        Card.fetch preference_card_id(setting_code, user), options
      end

      def preference_card_id setting_code, user=nil
        return unless (user_id = preference_user_id user)

        rule_id_lookup Card::Rule.preference_cache,
                       "#{setting_code}+#{user_id}",
                       "#{setting_code}+#{AllID}"
      end

      def rule?
        standard_rule? || preference?
      end

      def standard_rule?
        (Card.fetch_type_id(name.right) == SettingID) &&
          (Card.fetch_type_id(name.left) == SetID)
      end

      def preference?
        name.parts.length > 2 &&
          (Card.fetch_type_id(name.right) == SettingID) &&
          (Card.fetch_type_id(name[0..-3]) == SetID) &&
          valid_preferer?
      end

      private

      def valid_preferer?
        preferer = self[-2, skip_modules: true]
        (preferer.type_id == UserID) || (preferer.codename == :all)
      end

      def preference_user_id user
        case user
        when Integer then user
        when Card    then user.id
        when nil     then Auth.current_id
        else
          raise Card::ServerError, "invalid preference user"
        end
      end

      def rule_id_lookup lookup_hash, cache_suffix, fallback_suffix=nil
        rule_lookup_keys.each do |lookup_key|
          rule_id = lookup_hash["#{lookup_key}+#{cache_suffix}"]
          rule_id ||= fallback_suffix && lookup_hash["#{lookup_key}+#{fallback_suffix}"]
          return rule_id if rule_id
        end
        nil
      end
    end
  end
end
