# -*- encoding : utf-8 -*-

RSpec.describe Card::Query do
  describe "class_for" do
    it "handles symbols" do
      expect(Card::Query.class_for(:card)).to eq(Card::Query::CardQuery)
    end

    it "handles strings" do
      expect(Card::Query.class_for("reference")).to eq(Card::Query::ReferenceQuery)
    end
  end
end
