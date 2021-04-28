RSpec.describe Card::Set::Right::ApiKey do
  let(:new_key) { card_subject.generate }

  describe "generate" do
    it "creates a new key of at least twenty characters" do
      expect(new_key).to match(/\w{20,}/)
    end
  end

  describe "authenticate_api_key" do
    before { new_key } # trigger generation

    it "fails if api key is not exact match" do
      card_subject.authenticate_api_key new_key + "!"
      expect(card_subject.errors[:api_key_incorrect].first).to match(/API key mismatch/)
    end

    it "succeeds if api key is not exact match" do
      card_subject.authenticate_api_key new_key
      expect(card_subject.errors.first).to be_nil
    end
  end
end
