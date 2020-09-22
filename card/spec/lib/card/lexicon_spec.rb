# -*- encoding : utf-8 -*-

RSpec.describe Card::Lexicon do
  describe "#id" do
    it "finds ids for simple keys" do
      expect(Card::Lexicon.id("A")).to be_an(Integer)
    end

    it "finds ids for compound keys" do
      expect(Card::Lexicon.id("A+B")).to be_an(Integer)
    end

    it "finds ids for 2nd level compound keys" do
      expect(Card::Lexicon.id("A+B+C")).to be_an(Integer)
    end

    it "doesn't find ids for unknown keys" do
      expect(Card::Lexicon.id("A+B+C+ZZZZ")).not_to be_an(Integer)
    end
  end

  describe "#name" do
    it "handles simple cards" do
      id_of_simple_card = Card::Codename.id(:account)
      expect(Card::Lexicon.name(id_of_simple_card)).to eq("*account")
    end

    it "handles compound cards" do
      id_of_compound_card =
        Card.where(left_id: Card::Codename.id(:account),
                   right_id: Card::Codename.id(:right)).pluck(:id).first
      expect(Card::Lexicon.name(id_of_compound_card)).to eq("*account+*right")
    end
  end
end
