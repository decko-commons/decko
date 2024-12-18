FOLLOWER_IDS_CACHE_KEY = "FOLLOWER_IDS".freeze

card_accessor :followers, type: :list

event :cache_expired_for_type_change, :store, on: :update, changed: %i[type_id name] do
  act_card&.schedule_preference_expiration
  # FIXME: expire (also?) after save
  Card.follow_caches_expired
end

def schedule_preference_expiration
  @expire_preferences_scheduled = true
end

def expire_preferences?
  @expire_preferences_scheduled
end

event :expire_preferences_cache, :finalize, when: :expire_preferences? do
  Card::Rule.clear_preference_cache
end

# follow cache methods on Card class
module ClassMethods
  def follow_caches_expired
    Card.clear_follower_ids_cache
    Card::Rule.clear_preference_cache
  end

  def follower_ids_cache
    Card.cache.read(FOLLOWER_IDS_CACHE_KEY) || {}
  end

  def write_follower_ids_cache hash
    Card.cache.write FOLLOWER_IDS_CACHE_KEY, hash
  end

  def clear_follower_ids_cache
    Card.cache.write FOLLOWER_IDS_CACHE_KEY, nil
  end
end

def write_follower_ids_cache user_ids
  hash = Card.follower_ids_cache
  hash[id] = user_ids
  Card.write_follower_ids_cache hash
end

def read_follower_ids_cache
  Card.follower_ids_cache[id]
end

def follower_names
  followers.map(&:name)
end

def followers
  follower_ids.map do |id|
    Card.fetch(id)
  end
end

def follower_ids
  @follower_ids = read_follower_ids_cache || begin
    result = direct_follower_ids + indirect_follower_ids
    write_follower_ids_cache result
    result
  end
end

def followers_count
  follower_ids.size
end

def indirect_follower_ids
  result = Set.new
  left_card = left
  while left_card
    result += left_card.direct_follower_ids if left_card.followed_field? self
    left_card = left_card.left
  end
  result
end

# all users (cards) that "directly" follow this card
# "direct" means there is a follow rule that applies explicitly to this card.
# one can also "indirectly" follow cards by  following parent cards or other
# cards that nest this one.
def direct_followers
  direct_follower_ids.map do |id|
    Card.fetch(id)
  end
end

def direct_follower_ids &block
  ids = Set.new
  set_names.each do |set_name|
    direct_follower_ids_for_set setcard_from_name(set_name), ids, &block
  end
  ids
end

def setcard_from_name set_name
  Card.fetch set_name, new: { type_id: SetID }
end

def direct_follower_ids_for_set set_card, ids
  set_card.all_user_ids_with_rule_for(:follow).each do |user_id|
    next if ids.include?(user_id) || !(option = follow_rule_option user_id)

    yield user_id, set_card, option if block_given?
    ids << user_id
  end
end

def each_direct_follower_id_with_reason
  direct_follower_ids do |user_id, set_card, follow_option|
    reason = follow_option.gsub(/[\[\]]/, "")
    yield user_id, set_card: set_card, option: reason
  end
end
