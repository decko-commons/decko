RSpec.describe Card::Set::All::Follow::FollowLinkViews do
  xcontext "when not following" do
    def format_subject _format=nil
      Card["A"].format(:html)
    end

    specify "view :follow_link" do
      expect_view(:follow_button).to have_tag("a") do
        with_text "follow"
      end
    end
  end

  xcontext "when already following", with_user: "John" do
    def format_subject _format=nil
      Card["John Following"].format(:html)
    end

    specify "view :follow_link" do
      expect_view(:follow_button).to have_tag("a", with: {
                                                "data-hover-text": "unfollow"
                                              }) do
        with_text "following"
      end
    end
  end
end
