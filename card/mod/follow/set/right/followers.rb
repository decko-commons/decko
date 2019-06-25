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

def item_names _args={}
  return [] unless left
  left.follow_set_card.prototype.follower_names
end

def virtual?
  new?
end
