RSpec.describe Card::Set::All::Recursed do
  describe "#recursed_item_cards" do
    it "returns the 'leaf cards' of a tree of pointer cards" do
      Card::Auth.as_bot do
        Card.create!(name: "node", type: "Pointer", content: "[[Z]]")
      end
      c = Card.new(name: "foo", type: "Pointer", content: "[[node]]\n[[A]]")
      expect(c.recursed_item_cards).to eq([Card.fetch("Z"), Card.fetch("A")])
    end
  end

  describe "#recursed_item_contents" do
    it "returns the content of the 'leaf cards' of a tree of pointer cards" do
      Card::Auth.as_bot do
        Card.create!(name: "node", type: "Pointer", content: "[[Z]]")
      end
      c = Card.new(name: "foo", type: "Pointer", content:  "[[node]]\n[[T]]")
      expect(c.recursed_item_contents)
        .to eq(["I'm here to be referenced to", "Theta"])
    end
  end
end
