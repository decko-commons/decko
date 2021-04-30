class Card
  module Rule
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

      def is_rule?
        is_standard_rule? || is_preference?
      end

      def is_standard_rule?
        (Card.fetch_type_id(name.right) == SettingID) &&
          (Card.fetch_type_id(name.left) == SetID)
      end

      def is_preference?
        name.parts.length > 2 &&
          (Card.fetch_type_id(name.right) == SettingID) &&
          (self[0..-3, skip_modules: true]&.type_id == SetID) &&
          is_preferer?(self[-2, skip_modules: true])
      end

      private

      def is_preferer? preferer
        (preferer.type_id == UserID) || (preferer.codename == :all)
      end

      def preference_user_id user
        case user
        when Integer then user;
        when Card    then user
        when nil     then Auth.current_id
        else
          raise Card::ServerError, "invalid preference user"
        end
      end

      def rule_id_lookup lookup_hash, cache_suffix, fallback_suffix=nil
        rule_set_keys.each do |rule_set_key|
          rule_id = lookup_hash["#{rule_set_key}+#{cache_suffix}"]
          rule_id ||= fallback_suffix && lookup_hash["#{rule_set_key}+#{fallback_suffix}"]
          return rule_id if rule_id
        end
        nil
      end
    end
  end
end
