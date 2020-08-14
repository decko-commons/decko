# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::Name do
  describe "#descendants" do
    it "finds descendants" do
      expect(Card["A"].descendant_ids).to include(Card::Lexicon.id "A+B+C")
    end
  end
end
