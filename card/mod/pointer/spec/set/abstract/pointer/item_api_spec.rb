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
    let(:pointer) { Card.new name: "tp", type: "pointer" }

    it "add to empty ref list" do
      pointer.add_item "John"
      expect(pointer.content).to eq("[[John]]")
    end

    it "add to existing ref list" do
      pointer.content = "[[Jane]]"
      pointer.add_item "John"
      expect(pointer.content).to eq("[[Jane]]\n[[John]]")
    end

    it "not add duplicate entries" do
      pointer.content = "[[Jane]]"
      pointer.add_item "Jane"
      expect(pointer.content).to eq("[[Jane]]")
    end
  end

  describe "drop_item" do
    let :pointer do
      Card.new name: "tp", type: "pointer", content: "[[Jane]]\n[[John]]"
    end

    it "remove the link" do
      pointer.drop_item "Jane"
      expect(pointer.content).to eq("[[John]]")
    end

    it "not fail on non-existent reference" do
      pointer.drop_item "Bigfoot"
      expect(pointer.content).to eq("[[Jane]]\n[[John]]")
    end

    it "remove the last link" do
      pointer.drop_item "John"
      pointer.drop_item "Jane"
      pointer.content.should == ""
    end
  end
end
