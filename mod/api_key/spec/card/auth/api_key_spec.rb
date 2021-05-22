RSpec.describe Card::Auth::ApiKey do
  describe "signin_with_api_key" do
    let(:joe_admin) { Card["Joe Admin"] }

    let :api_key do
      Card::Auth.as_bot { joe_admin.account.api_key_card.generate! }
    end

    it "sets current from api key" do
      Card::Auth.signin_with_api_key api_key
      expect(Card::Auth.current_id).to eq(joe_admin.id)
    end
  end
end
