event :cache_expired_for_new_set, :store, on: :create do
  Card.follow_caches_expired
end

def follow_label
  if (klass = subclass_for_set)
    klass.short_label name.left
  else
    ""
  end
end

def follow_rule_name user=nil
  follower = case user
               when nil    then :all.cardname
               when String then user
               else             user.name
             end
  [name, follower, :follow.cardname].join "+"
end

def followed_by? user_id=nil
  all_members_followed_by? user_id
end

def default_follow_set_card
  self
end

def all_members_followed?
  all_members_followed_by? Auth.current_id
end

def all_members_followed_by? user_id=nil
  return false unless prototype.followed_by?(user_id)
  return true if set_followed_by? user_id
  broader_sets.each do |b_s|
    if (set_card = Card.fetch(b_s)) && set_card.set_followed_by?(user_id)
      return true
    end
  end
  false
end

def set_followed?
  set_followed_by? Auth.current_id
end

def set_followed_by? user_id=nil
  (
  user_id &&
      (user = Card.find(user_id)) && Card.fetch(follow_rule_name(user.name))
  ) || Card.fetch(follow_rule_name)
end
