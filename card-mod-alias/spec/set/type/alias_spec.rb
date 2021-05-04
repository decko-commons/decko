RSpec.describe Card::Set::Type::Alias do
  describe "alias?" do
    it "is true for simple Alias cards" do
      expect(card_subject).to be_alias
    end

    it "is false for simple non-Alias cards" do
      expect(Card["A"]).not_to be_alias
    end

    it "is false for compound non-alias cards" do
      expect(Card["A+B"]).not_to be_alias
    end

  end
end
