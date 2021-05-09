RSpec.describe Card::Rule do
  describe "#rule_cache" do
    it "translates special lookup keys into preference ids" do
      name = "Cardtype+*type+*structure"
      key = ["Cardtype".card_id, :type, :structure].map(&:to_s).join "+"
      expect(described_class.rule_cache[key]).to eq(name.card_id)
    end

    it "handles rules on *all set" do
      expect(described_class.rule_cache["all+default"]).to eq("*all+*default".card_id)
    end
  end

  describe "#preference_cache" do
    it "translates special lookup keys into preference ids" do
      name = "Sunglasses+*self+Sunglasses fan+*follow"
      key = ["Sunglasses".card_id, :self, :follow,
             "Sunglasses fan".card_id].map(&:to_s).join "+"
      expect(described_class.preference_cache[key]).to eq(name.card_id)
    end
  end
end
