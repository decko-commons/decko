# -*- encoding : utf-8 -*-

# X+*followers provides a list of all users following X.

include_set Abstract::List

format :html do
  view :core, cache: :never do
    super()
  end
end

def content
  left ? item_names.to_pointer_content : ""
end

def item_names _args={}
  left ? left.follow_set_card.prototype.follower_names : []
end

def virtual?
  new?
end
