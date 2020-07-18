# -*- encoding : utf-8 -*-

RSpec.describe Card::Name::Real do
  describe "#id" do
    it "finds ids for simple keys" do
      expect(Card::Name.id("A")).to be_an(Integer)
    end

    it "finds ids for compound keys" do
      expect(Card::Name.id("A+B")).to be_an(Integer)
    end

    it "finds ids for 2nd level compound keys" do
      expect(Card::Name.id("A+B+C")).to be_an(Integer)
    end

    it "doesn't find ids for unknown keys" do
      expect(Card::Name.id("A+B+C+ZZZZ")).not_to be_an(Integer)
    end
  end
end
