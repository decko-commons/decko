#! no set module

class StartFollowLink < FollowLink
  def initialize format
    @rule_content = "*always"
    @link_text = "follow"
    @action = "send"
    @css_class = ""
    super
  end
end
