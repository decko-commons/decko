# for override
def followable?
  true
end

def follow_label
  name
end

def list_direct_followers?
  false
end

def follow_option?
  codename && FollowOption.codenames.include?(codename)
end

# the set card to be followed if you want to follow changes of card
def follow_set_card
  Card.fetch name, :self
end

def follow_rule_name user=nil
  follow_set_card&.follow_rule_name user
end

def follow_rule_card user=nil, args={}
  Card.fetch follow_rule_name(user), args
end

def follow_rule? user=nil
  Card.exist? follow_rule_name(user)
end
