RSpec.describe Card::Auth::Token do
  let :joe_user_id do
    "joe user".card_id
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
      expect(described_class.decode("#{encoded_token}XYZ"))
        .to eq("Signature verification failed")
    end

    it "detects expired tokens" do
      token = described_class.encode joe_user_id, exp: 10.days.ago.to_i
      expect(described_class.decode(token)).to eq("Signature has expired")
    end
  end
end
