# -*- encoding : utf-8 -*-

describe Card::Set::All::Name do
  describe "#descendants" do
    it "finds descendants" do
      expect(Card["A"].descendants.length).to be > 0
    end
  end
end
