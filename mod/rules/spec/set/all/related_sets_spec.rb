RSpec.describe Card::Set::All::RelatedSets do
  describe "#related_sets" do
    it "has 1 set (right) for a simple card" do
      sets = "A".card.related_sets.map(&:name)
      expect(sets).to eq(["A+*right"])
    end

    it "has 2 sets (type, and right) for a cardtype card" do
      sets = "Cardtype A".card.related_sets.map(&:name)
      expect(sets).to eq(["Cardtype A+*type", "Cardtype A+*right"])
    end

    # it "shows type plus right sets when they exist" do
    #   Card::Auth.as_bot do
    #     Card.create name: 'RichText+A+*type plus right', content: ''
    #   end
    #   sets = Card['A'].related_sets
    #   sets.should == ['A+*self', 'A+*right', 'RichText+A+*type plus right']
    # end
    # it "shows type plus right sets when they exist, and type" do
    #   Card::Auth.as_bot do
    #     Card.create name: 'RichText+Cardtype A+*type plus right', content: ''
    #   end
    #   sets = Card['Cardtype A'].related_sets
    #   sets.should == ['Cardtype A+*self', 'Cardtype A+*type',
    #     'Cardtype A+*right', 'RichText+Cardtype A+*type plus right']
    # end

    it "is empty for a non-simple card" do
      sets = "A+B".card.related_sets.map(&:name)
      expect(sets).to eq([])
    end
  end
end
