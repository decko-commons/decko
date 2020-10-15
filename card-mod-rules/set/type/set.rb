include_set Type::SearchType

def anchor_name
  name.left_name
end

def anchor
  Card[anchor_name]
end

def pattern_name
  name.tag_name
end

def pattern
  tag
end

def inheritable?
  junction_only? || (anchor_name&.junction? && self_set?)
end

def self_set?
  pattern_name == Card::Set::Self.pattern.key
end

def subclass_for_set
  current_set_pattern_code = pattern.codename
  Card.set_patterns.find { |set| set.pattern_code == current_set_pattern_code }
end

def junction_only?
  @junction_only.nil? ? (@junction_only = subclass_for_set.junction_only) : @junction_only
end

def label
  klass = subclass_for_set
  klass ? klass.label(anchor_name) : ""
end

def uncapitalized_label
  label = label.to_s
  return label unless label[0]

  label[0] = label[0].downcase
  label
end

def rule_cache_key_base
  if (l = left) && (r = right)
    "#{l.id}+#{Codename[r.id]}"
  else
    Codename[id].to_s
  end
end

def all_user_ids_with_rule_for setting_code
  Card::Rule.all_user_ids_with_rule_for self, setting_code
end

def setting_codenames_by_group
  result = {}
  Card::Setting.groups.each do |group, settings|
    visible_settings =
      settings.reject { |s| !s || !s.applies_to_cardtype(prototype.type_id) }
    result[group] = visible_settings.map(&:codename) unless visible_settings.empty?
  end
  result
end

def visible_setting_codenames
  @visible_setting_codenames ||= visible_settings.map(&:codename)
end

def visible_settings group=nil, cardtype_id=nil
  cardtype_id ||= prototype.type_id
  settings =
    (group && Card::Setting.groups[group]) || Card::Setting.groups.values.flatten.compact
  settings.reject do |setting|
    !setting || !setting.applies_to_cardtype(cardtype_id)
  end
end

def broader_sets
  prototype.set_names[1..-1]
end

def prototype
  opts = subclass_for_set.prototype_args anchor_name
  Card.fetch opts[:name], new: opts
end

def prototype_default_type_id
  prototype_default_card.type_id
end

def prototype_default_card
  prototype.rule_card(:default)
end

def related_sets with_self=false
  if subclass_for_set.anchorless?
    prototype.related_sets with_self
  else
    left(new: {}).related_sets with_self
  end
end
