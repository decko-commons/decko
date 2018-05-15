def follow_label
  default_follow_set_card.follow_label
end

def followed_by? user_id=nil
  default_follow_set_card.all_members_followed_by? user_id
end

def default_follow_set_card
  Card.fetch name, :type
end
