
RSpec.describe Card::Set::All::Follow::StopFollowLink do
  describe "bridge link" do
    subject do
      described_class.new(Card["A"].format).button
    end

    specify do
      is_expected.to have_tag "a[href*='never']", with: {
        "data-hover-text": "unfollow",
      }, text: /following/
    end
  end
end