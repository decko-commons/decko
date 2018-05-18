
include_set Type::SearchType

def inheritable?
  return true if junction_only?
  name.trunk_name.junction? &&
    name.tag_name.key == Card::Set::Self.pattern.key
end

def subclass_for_set
  current_set_pattern_code = tag.codename
  Card.set_patterns.find do |set|
    current_set_pattern_code == set.pattern_code
  end
end

def junction_only?
  if @junction_only.nil?
    @junction_only = subclass_for_set.junction_only
  else
    @junction_only
  end
end

def label
  if (klass = subclass_for_set)
    klass.label name.left
  else
    ""
  end
end

def uncapitalized_label
  label = label.to_s
  return label unless label[0]
  label[0] = label[0].downcase
  label
end

def all_user_ids_with_rule_for setting_code
  Card.all_user_ids_with_rule_for self, setting_code
end

def setting_codenames_by_group
  result = {}
  Card::Setting.groups.each do |group, settings|
    visible_settings =
      settings.reject { |s| !s || !s.applies_to_cardtype(prototype.type_id) }
    unless visible_settings.empty?
      result[group] = visible_settings.map(&:codename)
    end
  end
  result
end

def visible_setting_codenames
  @visible_settings ||=
    Card::Setting.groups.values.flatten.compact.select do |setting|
      setting.applies_to_cardtype(prototype.type_id)
    end.map(&:codename)
end

def visible_settings group
  Card::Setting.groups[group].reject do |setting|
    !setting || !setting.applies_to_cardtype(prototype.type_id)
  end
end

def broader_sets
  prototype.set_names[1..-1]
end

def prototype
  opts = subclass_for_set.prototype_args name.trunk_name
  Card.fetch opts[:name], new: opts
end

def related_sets with_self=false
  if subclass_for_set.anchorless?
    prototype.related_sets with_self
  else
    left(new: {}).related_sets with_self
  end
end
