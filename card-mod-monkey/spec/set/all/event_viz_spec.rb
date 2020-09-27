# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::EventViz do
  describe '#events' do
    it "has at least twenty events" do
      expect(Card['A'].events(:update).split("\n").length).to be >= 20
    end
  end
end
