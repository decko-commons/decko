event :save_recently_edited_settings, :integrate, on: :save, changed: %i[type content] do
  if (recent = Card[:recent_settings])
    recent.insert_item 0, name.right
    subcard recent
  end
end

def rule_set_key
  rule_set_name.key
end

def rule_set_name
  if preference?
    name.trunk_name.trunk_name
  else
    name.trunk_name
  end
end

def rule_set_pattern_name
  rule_set_name.tag_name
end

def rule_set
  if preference?
    self[0..-3]
  else
    trunk
  end
end

def rule_setting
  right
end

def rule_setting_name
  name.tag
end

def short_help_text
  Card[rule_setting_name].short_help_text
end

def rule_setting_title
  rule_setting_name.tr "*", ""
end

def rule_user_setting_name
  if preference?
    "#{rule_user_name}+#{rule_setting_name}"
  else
    rule_setting_name
  end
end

# ~~~~~~~~~~ determine the set options to which a user can apply the rule.
def set_options
  @set_options ||= [].tap do |set_options|
    set_option_candidates.each do |set_name|
      set_options << [set_name, state_of_set(set_name)]
    end
  end
end

# the narrowest rule should be the one attached to the set being viewed.
# So, eg, if you're looking at the '*all plus' set, you shouldn't
# have the option to create rules based on arbitrary narrower sets, though
# narrower sets will always apply to whatever prototype we create
def first_set_option_index candidates
  new_card? ? 0 : candidates.index { |c| c.to_name.key == rule_set_key }
end

def set_prototype
  if preference?
    self[0..-3].prototype
  else
    trunk.prototype
  end
end

private

def set_option_candidates
  candidates = set_prototype.set_names
  first = first_set_option_index candidates
  candidates[first..-1]
end

def state_of_set set_name
  @sets_with_existing_rules ||= 0
  if rule_for_set? set_name
    @sets_with_existing_rules += 1
    state_of_existing_set
  else
    state_of_nonexisting_set
  end
end

def state_of_existing_set
  @sets_with_existing_rules == 1 ? :current : :overwritten
end

def state_of_nonexisting_set
  @sets_with_existing_rules.positive? ? :overwritten : :available
end

def rule_for_set? set_name
  Card.exist?("#{set_name}+#{rule_user_setting_name}")
end
