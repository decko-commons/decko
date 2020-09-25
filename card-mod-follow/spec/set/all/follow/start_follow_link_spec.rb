RSpec.describe Card::Set::All::Follow::StartFollowLink do
  describe "bridge link" do
    subject(:button) do
      described_class.new(Card["A"].format).button
    end

    specify do
      expect(button).to have_tag "a[href*='always']", "follow"
    end
  end
end
