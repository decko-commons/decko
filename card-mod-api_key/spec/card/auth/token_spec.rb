RSpec.describe Card::Auth::Token do
  let :joe_user_id do
    Card.fetch_id "joe user"
  end

  let :encoded_token do
    described_class.encode joe_user_id
  end

  describe "#encode" do
    it "encodes simple token" do
      expect(encoded_token.length).to be > 10
    end
  end

  describe "#decode" do
    it "decodes simple token" do
      expect(described_class.decode(encoded_token)[:user_id]).to eq(joe_user_id)
    end

    it "handles invalid tokens" do
      expect(described_class.decode(encoded_token + "XYZ"))
        .to eq("Signature verification raised")
    end

    it "detects expired tokens" do
      token = described_class.encode joe_user_id, exp: 10.days.ago.to_i
      expect(described_class.decode(token)).to eq("Signature has expired")
    end
  end

  describe "signin_with_api_key" do
    let(:joe_admin) { Card["Joe Admin"] }
    let(:api_key) { "abcd" }

    before do
      Card::Auth.as_bot do
        joe_admin.account.api_key_card.update! content: api_key
      end
    end

    it "sets current from api key" do
      Card::Auth.signin_with_api_key api_key
      expect(Card::Auth.current_id).to eq(joe_admin.id)
    end
  end
end
