#! no set module

# links to begin following card sets
class StartFollowLink < FollowLink
  def initialize format
    @rule_content = "*always"
    @link_text = "follow"
    @action = "send"
    @css_class = ""
    super
  end
end
