
def is_rule?
  is_standard_rule? || is_preference?
end

def is_standard_rule?
  (r = right(skip_modules: true)) &&
    r.type_id == SettingID &&
    (l = left(skip_modules: true)) &&
    l.type_id == SetID
end

# TODO: abstract so account doesn't have to have User type.
def is_preference?
  name.parts.length > 2 &&
    (r = right(skip_modules: true)) &&
    r.type_id == SettingID &&
    (set = self[0..-3, skip_modules: true]) &&
    set.type_id == SetID &&
    (user = self[-2, skip_modules: true]) &&
    (user.type_id == UserID || user.codename == :all)
end

def rule setting_code, options={}
  options[:skip_modules] = true
  card = rule_card setting_code, options
  card && card.db_content
end

def rule_card setting_code, options={}
  Card.fetch rule_card_id(setting_code, options), options
end

def rule_card_id setting_code, options={}
  fallback = options.delete :fallback

  if Card::Setting.user_specific? setting_code
    fallback, setting_code = preference_card_id_lookups setting_code, options
  end

  rule_set_keys.each do |rule_set_key|
    rule_cache = Card::Rule.rule_cache
    rule_id = rule_cache["#{rule_set_key}+#{setting_code}"]
    rule_id ||= fallback && rule_cache["#{rule_set_key}+#{fallback}"]
    return rule_id if rule_id
  end
  nil
end

def preference_card_id_lookups setting_code, options={}
  user_id = options[:user_id] || options[:user]&.id || Auth.current_id
  return unless user_id
  ["#{setting_code}+#{AllID}", "#{setting_code}+#{user_id}"]
end

def related_sets with_self=false
  # refers to sets that users may configure from the current card -
  # NOT to sets to which the current card belongs

  sets = []
  sets << ["#{name}+*self", Card::Set::Self.label(name)] if with_self
  if known? && name.simple?
    sets << ["#{name}+*right", Card::Set::Right.label(name)]
  end
  sets
end
