RSpec.describe Card::Set::All::Autoname do
  describe "event: set_autoname" do
    before do
      Card::Auth.as_bot { Card.create! name: "Book+*type+*autoname", content: "b1" }
    end

    it "handles cards without names" do
      c = Card.create! type: "Book"
      expect(c.name).to eq("b1")
    end

    it "increments again if name already exists" do
      _b1 = Card.create! type: "Book"
      b2 = Card.create! type: "Book"
      expect(b2.name).to eq("b2")
    end

    it "handles trashed names" do
      b1 = Card.create! type: "Book"
      Card::Auth.as_bot { b1.delete }
      b1 = Card.create! type: "Book"
      expect(b1.name).to eq("b1")
    end
  end

end
