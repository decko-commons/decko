FOLLOWER_IDS_CACHE_KEY = "FOLLOWER_IDS".freeze

card_accessor :followers

event :cache_expired_for_type_change, :store,
      on: :update, changed: %i[type_id name] do
  # FIXME: expire (also?) after save
  Card.follow_caches_expired
end

# follow cache methods on Card class
module ClassMethods
  def follow_caches_expired
    Card.clear_follower_ids_cache
    Card.clear_preference_cache
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
    result = direct_follower_ids
    left_card = left
    while left_card
      result += left_card.direct_follower_ids if left_card.followed_field? self
      left_card = left_card.left
    end
    write_follower_ids_cache result
    result
  end
end

def direct_followers
  direct_follower_ids.map do |id|
    Card.fetch(id)
  end
end

# all ids of users that "directly" follow this card
# "direct" means there is a follow rule that applies explicitly to this card.
# one can also "indirectly" follow cards by  following parent cards or other
# cards that nest this one.
def direct_follower_ids _args={}
  all_direct_follower_ids
end

def all_direct_follower_ids_with_reason
  all_direct_follower_ids do |user_id, set_card, follow_option|
    yield user_id, set_card: set_card, option: follow_option
  end
end

def all_direct_follower_ids
  ids = ::Set.new
  each_direct_follower_id do |user_id, set_card|
    next unless (follow_option = direct_follower_option user_id, ids)
    ids << user_id
    yield user_id, set_card, follow_option if block_given?
  end
  ids
end

def direct_follower_option user_id, ids
  return if ids.include? user_id
  follow_rule_applies? user_id
end

def each_direct_follower_id
  with_follower_candidate_ids do
    set_names.each do |set_name|
      set_card = Card.fetch(set_name)
      set_card.all_user_ids_with_rule_for(:follow).each do |user_id|
        yield user_id, set_card
      end
    end
  end
end

def follow_rule_applies? follower_id
  each_follow_rule_option follower_id do |option|
    next unless follow_rule_option_applies? follower_id, option
    # FIXME: method ending in question mark should return True/False
    return option.gsub(/[\[\]]/, "")
  end
  false
end

def follow_rule_option_applies? follower_id, option
  option_code = option.to_name.code
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

def each_follow_rule_option follower_id
  follow_rule = rule :follow, user_id: follower_id
  return unless follow_rule.present?
  follow_rule.split("\n").each do |option|
    yield option
  end
end

def with_follower_candidate_ids
  @follower_candidate_ids = {}
  yield
  @follower_candidate_ids = nil
end
