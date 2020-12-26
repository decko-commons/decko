# -*- encoding : utf-8 -*-

RSpec.describe Card::Name::All do
  describe "#each_descendants" do
    it "finds descendants" do
      descendants_of_a = []
      Card["A"].each_descendant { |card| descendants_of_a << card.name }
      expect(descendants_of_a).to include("A+B+C")
    end
  end
end
