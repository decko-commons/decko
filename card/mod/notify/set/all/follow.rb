# for override
def followable?
  true
end

# for override
def follow_label
  name
end

# the set card to be followed if you want to follow changes of card
def default_follow_set_card
  Card.fetch("#{name}+*self")
end

def follow_option?
  codename && FollowOption.codenames.include?(codename)
end

# used for the follow menu overwritten in type/set.rb and type/cardtype.rb
# for sets and cardtypes it doesn't check whether the users is following the
# card itself instead it checks whether he is following the complete set
def followed_by? user_id
  with_follower_candidate_ids do
    return true if follow_rule_applies? user_id
    return true if (left_card = left) &&
                   left_card.followed_field?(self) &&
                   left_card.followed_by?(user_id)
    false
  end
end

def followed?
  followed_by? Auth.current_id
end

# returns true if according to the follow_field_rule followers of self also
# follow changes of field_card
def followed_field? field_card
  (follow_field_rule = rule_card(:follow_fields)) ||
    follow_field_rule.item_names.find do |item|
      item.to_name.key == field_card.key ||
        (item.to_name.key == Card[:includes].key &&
         includee_ids.include?(field_card.id))
    end
end
