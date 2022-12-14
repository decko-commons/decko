event :cache_expired_for_new_set, :store, on: :create do
  Card.follow_caches_expired
end

def list_direct_followers?
  true
end

def follow_label
  if (klass = subclass_for_set)
    klass.short_label name.left_name
  else
    ""
  end
end

def follow_rule_name user=nil
  Card::Name[[name, user, :follow].compact]
end

def followed_by? user_id=nil
  all_members_followed_by? user_id
end

def follow_set_card
  self
end

def all_members_followed?
  all_members_followed_by? Auth.current_id
end

def all_members_followed_by? user_id=nil
  return false unless prototype.followed_by?(user_id)

  directly_followed_by?(user_id) || broader_set_followed_by?(user_id)
end

def broader_set_followed_by? user_id
  broader_sets.find do |set_card|
    set_card&.directly_followed_by? user_id
  end
end

def directly_followed?
  directly_followed_by? Auth.current_id
end

def directly_followed_by? user_id=nil
  return true if user_id && follow_rule?(user_id)

  follow_rule?
end
