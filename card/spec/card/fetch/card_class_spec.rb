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
      expect(Card.exist?("A")).to eq(true)
    end

    it "is false for cards that aren't" do
      expect(Card.exist?("Mumblefunk is gone")).to eq(false)
    end
  end

  describe "#quick_fetch" do
    example "symbol" do
      expect(Card.quick_fetch(:all).name).to eq "*all"
    end

    example "string" do
      expect(Card.quick_fetch("home").name).to eq "Home"
    end

    example "id" do
      expect(Card.quick_fetch(Card::BasicID).name).to eq "RichText"
    end

    example "invalid id" do
      expect(Card.quick_fetch("~1836/[[/assets/fonts")).to be_nil
    end

    example "array" do
      expect(Card.quick_fetch(%w[a b]).name).to eq "A+B"
    end

    example "param list" do
      expect(Card.quick_fetch("fruit", :type, "*create").name).to eq "Fruit+*type+*create"
    end

    example "name doesn't exist" do
      expect(Card.quick_fetch("unknown_name")).to eq nil
    end

    it "doesn't fetch virtual names" do
      expect(Card.quick_fetch(:all, :self, :create)).to eq nil
    end
  end
end
