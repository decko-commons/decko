RSpec.describe Card::Set::TypePlusRight::User::Follow do
  def card_subject
    Card.fetch "Big Brother+*follow"
  end

  check_views_for_errors

  describe "view :core" do
    it "renders tab content" do
      expect_view(:core).to match(/All Eyes On Me/)
    end
  end
end
