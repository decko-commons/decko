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

  describe "validate_api_key" do
    it "accepts generated keys" do
      new_key # trigger generation
      expect(card_subject.valid?).to be_truthy
    end

    it "validates length" do
      card_subject.content ="abcdefg555"
      expect(card_subject.valid?).to be_falsey
    end

    it "catches duplicates" do
      create_card "Joe User+*api key", content: new_key
      new_card = Card.new name: "Joe User+*api key", content: new_key
      expect(new_card.valid?).to be_falsey
    end
  end
end
