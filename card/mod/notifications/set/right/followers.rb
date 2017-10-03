# -*- encoding : utf-8 -*-

# X+*followers provides a list of all users following X.

include Card::Set::Type::Pointer

format do
  include Card::Set::Type::Pointer::Format
end

format :html do
  include Card::Set::Type::Pointer::HtmlFormat
end

format :html do
  view :core, cache: :never do
    super()
  end
end

def raw_content
  return "" unless left
  items =
    if (left.type_id == SetID) || (left.type_id == CardtypeID)
      set_card = left.default_follow_set_card
      set_card.all_user_ids_with_rule_for(:follow).map do |user_id|
        if left.followed_by?(user_id) && (user = Card.find(user_id))
          user.name
        end
      end.compact
    else
      left.follower_names
    end
  items.map { |item| "[[#{item}]]" }.join "\n"
end

def virtual?
  !real?
end
