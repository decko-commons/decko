#! no set module

class StopFollowLink < FollowLink
  def initialize format
    @rule_content = "*never"
    @link_text = "following"
    @hover_text = "unfollow"
    @action = "stop sending"
    @css_class = "btn-item-delete"
    super
  end
end
