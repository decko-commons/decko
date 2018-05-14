# -*- encoding : utf-8 -*-

# X+*followers provides a list of all users following X.

include_set Abstract::Pointer

format :html do
  view :core, cache: :never do
    super()
  end
end

def content
  return "" unless left
  item_names.map { |item| "[[#{item}]]" }.join "\n"
end

def item_names
  return [] unless left
  special_left_followers || left.follower_names
end

# FIXME: should be handled in sets
def special_left_followers
  return unless [SetID, CardtypeID].include? left.type_id
  set_card = left.default_follow_set_card
  set_card.all_user_ids_with_rule_for(:follow).map do |user_id|
    if left.followed_by?(user_id) && (user = Card.find(user_id))
      user.name
    end
  end.compact
end

def virtual?
  !real?
end
