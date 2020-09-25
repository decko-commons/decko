RSpec.describe Card::Rule do
  describe "#rule_cache" do
    it "translates special lookup keys into preference ids" do
      name = "Cardtype+*type+*structure"
      key = ["Cardtype".to_name.card_id, :type, :structure].map(&:to_s).join "+"
      expect(Card::Rule.rule_cache[key]).to eq(Card.fetch_id name)
    end

    it "handles rules on *all set" do
      expect(Card::Rule.rule_cache["all+default"]).to eq(Card.fetch_id("*all+*default"))
    end
  end

  describe "#preference_cache" do
    it "translates special lookup keys into preference ids" do
      name = "Sunglasses+*self+Sunglasses fan+*follow"
      key = ["Sunglasses".to_name.card_id, :self, :follow,
             "Sunglasses fan".to_name.card_id].map(&:to_s).join "+"
      expect(Card::Rule.preference_cache[key]).to eq(Card.fetch_id name)
    end
  end

  describe "#rule_cache" do
    it "translates special lookup keys into preference ids" do
      name = "Cardtype+*type+*structure"
      key = ["Cardtype".to_name.card_id, :type, :structure].map(&:to_s).join "+"
      expect(Card::Rule.rule_cache[key]).to eq(Card.fetch_id name)
    end
  end
end
