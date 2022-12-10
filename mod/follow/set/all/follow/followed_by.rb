# used by +:followers overwritten in type/set.rb and type/cardtype.rb
def followed?
  followed_by? Auth.current_id
end

# for sets and cardtypes it doesn't check whether the users is following the
# card itself instead it checks whether he is following the complete set
def followed_by? user_id
  follow_rule_applies?(user_id) || left&.followed_by_as_field?(self, user_id)
end

def followed_by_as_field? field, user_id
  followed_field?(field) && followed_by?(user_id)
end

# returns true if according to the follow_field_rule followers of self also
# follow changes of field_card
def followed_field? field_card
  return unless (follow_field_rule = rule_card(:follow_fields))

  follow_field_rule.item_names(context: self).find do |item|
    case item.to_name.key
    when field_card.key         then true
    when :nests.cardname.key then nested_card?(field_card)
    end
  end
end

def nested_card? card
  nestee_ids.include? card.id
end

## the following methods all handle _explicit_ (direct) follow rules (not fields)

def follow_rule_applies? follower_id
  !follow_rule_option(follower_id).nil?
end

def follow_rule_option follower_id
  all_follow_rule_options(follower_id).find do |option|
    follow_rule_option_applies? follower_id, option
  end
end

def all_follow_rule_options follower_id
  follow_rule = preference :follow, follower_id
  return [] unless follow_rule.present?

  follow_rule.split("\n")
end

def follow_rule_option_applies? follower_id, option
  option_code = option.to_name.codename
  candidate_ids = follower_candidate_ids_for_option option_code
  follow_rule_option_applies_to_candidates? follower_id, option_code, candidate_ids
end

def follow_rule_option_applies_to_candidates? follower_id, option_code, candidate_ids
  if (test = FollowOption.test[option_code])
    test.call follower_id, candidate_ids
  else
    candidate_ids.include? follower_id
  end
end

def follower_candidate_ids_for_option option_code
  return [] unless (block = FollowOption.follower_candidate_ids[option_code])

  block.call self
end
