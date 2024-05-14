RSpec.describe Card::Set::Right::ApiKey do
  let(:new_key) { subject.generate }
  let(:user) { "Joe User".card }
  subject { user.account.api_key_card }

  describe "#generate" do
    it "creates a new key of at least twenty characters" do
      expect(new_key).to match(/\w{20,}/)
    end
  end

  describe "#authenticate_api_key" do
    before do
      new_key
      subject.save!
    end

    it "fails if api key is not exact match" do
      subject.authenticate_api_key "#{new_key}!"
      expect(subject.errors[:api_key_incorrect].first).to match(/API key mismatch/)
    end

    it "succeeds if api key is not exact match" do
      subject.authenticate_api_key new_key
      expect(subject.errors.first).to be_nil
    end
  end

  describe "#validate_api_key" do
    it "accepts generated keys" do
      new_key # trigger generation
      is_expected.to be_valid
    end

    it "validates length" do
      subject.content = "abcdefg555"
      is_expected.not_to be_valid
    end

    it "catches duplicates" do
      create_card "Joe User+*account+*api key", content: new_key
      new_card = Card.new name: "Joe Admin+*account*api key", content: new_key
      expect(new_card).not_to be_valid
    end
  end

  specify "#accounted" do
    expect(subject.accounted).to eq(user)
  end

  describe "permissions" do
    before do
      Card::Auth.signin user
    end

    it "allows users to read their own key" do
      is_expected.to be_ok(:read)
    end

    it "allows users to update their own key" do
      Card::Auth.as_bot do
        subject.generate
        subject.save!
      end
      is_expected.to be_ok(:update)
    end

    it "allows users to create their own key" do
      is_expected.to be_ok(:create)
    end

    it "does not allow users to see others' keys" do
      expect(Card.fetch("Joe Camel+*account+*api key", new: {})).not_to be_ok(:read)
    end
  end
end
