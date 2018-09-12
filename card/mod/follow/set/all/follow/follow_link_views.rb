format do
  def follow_link_class
    card.followed? ? StopFollowLink : StartFollowLink
  end

  def show_follow?
    Auth.signed_in? && !card.new_card? && card.followable?
  end
end

format :json do
  view :follow_status do
    follow_link_class.link_opts
  end
end

format :html do
  def follow_link
    follow_link_class.new(self).modal_link
  end

  view :follow_link do
    follow_link
  end
end
