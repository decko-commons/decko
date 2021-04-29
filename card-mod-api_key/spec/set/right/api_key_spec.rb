RSpec.describe Card::Set::Right::ApiKey do
  let(:new_key) { card_subject.generate }
  let(:user) { Card["Joe User"] }
  let(:user_key) { user.account.api_key_card }

  describe "#generate" do
    it "creates a new key of at least twenty characters" do
      expect(new_key).to match(/\w{20,}/)
    end
  end

  describe "#authenticate_api_key" do
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

  describe "#validate_api_key" do
    it "accepts generated keys" do
      new_key # trigger generation
      expect(card_subject).to be_valid
    end

    it "validates length" do
      card_subject.content = "abcdefg555"
      expect(card_subject).not_to be_valid
    end

    it "catches duplicates" do
      create_card "Joe User+*account+*api key", content: new_key
      new_card = Card.new name: "Joe Admin+*account*api key", content: new_key
      expect(new_card).not_to be_valid
    end
  end

  specify "#accounted" do
    expect(user_key.accounted).to eq(user)
  end

  describe "permissions" do
    before do
      Card::Auth.signin user
    end

    it "allows users to read their own key" do
      expect(user_key.ok?(:read)).to be_truthy
    end

    it "allows users to update their own key" do
      Card::Auth.as_bot do
        user_key.generate
        user_key.save!
      end
      expect(user_key.ok?(:update)).to be_truthy
    end

    it "allows users to create their own key" do
      expect(user_key.ok?(:create)).to be_truthy
    end
  end
end
