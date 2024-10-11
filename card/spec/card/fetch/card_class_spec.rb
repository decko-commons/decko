RSpec.describe Card::Fetch::CardClass do
  describe "#id" do
    it "handles integer args" do
      expect(Card.id(1234)).to eq(1234)
    end

    it "handles card args" do
      a = Card["A"]
      expect(Card.id(a)).to eq(a.id)
    end

    it "handles symbols" do
      expect(Card.id(:structure)).to eq(Card::StructureID)
    end
  end

  describe "#exists?" do
    it "is true for cards that are there" do
      expect(Card.exists?("A")).to eq(true)
    end

    it "is false for cards that aren't" do
      expect(Card.exists?("Mumblefunk is gone")).to eq(false)
    end
  end

  describe "#fetch_name" do
    example "symbol" do
      expect(Card.fetch_name(:all)).to eq "*all"
    end

    example "string" do
      expect(Card.fetch_name("home")).to eq "Home"
    end

    example "id" do
      expect(Card.fetch_name(Card::BasicID)).to eq "RichText"
    end

    example "invalid id" do
      expect(Card.fetch_name("~1836/[[/assets/fonts")).to be_nil
    end

    example "array" do
      expect(Card.fetch_name(%w[a b])).to eq "A+B"
    end

    example "param list" do
      expect(Card.fetch_name("fruit", :type, "*create")).to eq "Fruit+*type+*create"
    end

    example "name doesn't exist" do
      expect(Card.fetch_name("unknown_name")).to eq nil
    end

    it "doesn't fetch virtual names" do
      expect(Card.fetch_name(:all, :self, :create)).to eq nil
    end
  end
end
