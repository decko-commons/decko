describe Card::Set::All::Follow::FollowLink do
  # SPECSTUB
  specify "view follow_link" do
    expect_view(:follow_link).to have_tag("a") do
      with_tag "span.follow-verb.menu-item-label"
    end
  end
end
