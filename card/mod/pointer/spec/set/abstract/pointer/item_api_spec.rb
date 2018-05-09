# -*- encoding : utf-8 -*-

describe Card::Set::Abstract::Pointer do
  describe "item_names" do
    it "returns array of names of items referred to by a pointer" do
      card = Card.new(type: "Pointer", content: "[[Busy]]\n[[Body]]")
      card.item_names.should == %w[Busy Body]
    end

    it "ignores invalid names" do
      card = Card.new(type: "Pointer", content: "[[Busy]]\n[[~9999]]")
      expect(card.item_names).to eq(["Busy"])
    end
  end

  describe "add_item" do
    it "add to empty ref list" do
      pointer = Card.new name: "tp", type: "pointer", content: ""
      pointer.add_item "John"
      pointer.content.should == "[[John]]"
    end

    it "add to existing ref list" do
      pointer = Card.new name: "tp", type: "pointer", content: "[[Jane]]"
      pointer.add_item "John"
      pointer.content.should == "[[Jane]]\n[[John]]"
    end

    it "not add duplicate entries" do
      pointer = Card.new name: "tp", type: "pointer", content: "[[Jane]]"
      pointer.add_item "Jane"
      pointer.content.should == "[[Jane]]"
    end
  end

  describe "drop_item" do
    it "remove the link" do
      content = "[[Jane]]\n[[John]]"
      pointer = Card.new name: "tp", type: "pointer", content: content
      pointer.drop_item "Jane"
      pointer.content.should == "[[John]]"
    end

    it "not fail on non-existent reference" do
      content = "[[Jane]]\n[[John]]"
      pointer = Card.new name: "tp", type: "pointer", content: content
      pointer.drop_item "Bigfoot"
      pointer.content.should == content
    end

    it "remove the last link" do
      pointer = Card.new name: "tp", type: "pointer", content: "[[Jane]]"
      pointer.drop_item "Jane"
      pointer.content.should == ""
    end
  end
end
