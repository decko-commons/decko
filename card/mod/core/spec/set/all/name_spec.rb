# -*- encoding : utf-8 -*-

describe Card::Set::All::Name do
  describe "#repair_key" do
    it "fixes broken keys" do
      a = Card["a"]
      a.update_column "key", "broken_a"
      a.expire

      a = Card.find a.id
      expect(a.key).to eq("broken_a")
      a.repair_key
      expect(a.key).to eq("a")
    end
  end

  describe "#descendants" do
    it "finds descendants" do
      expect(Card["A"].descendants.length).to be > 0
    end
  end
end
