# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::List do
  context "with two items" do
    let :pointer do
      Card.new type: "Pointer", content: "[[Busy]]\n[[Body]]"
    end

    describe "item_names" do
      it "returns array of names of items referred to by a pointer" do
        expect(pointer.item_names).to eq(%w[Busy Body])
      end

      it "ignores invalid names" do
        pointer.content = "[[Busy]]\n[[~9999]]"
        expect(pointer.item_names).to eq(["Busy"])
      end

      it "handles limits" do
        expect(pointer.item_names(limit: 1)).to eq(["Busy"])
      end

      it "handles offsets" do
        expect(pointer.item_names(offset: 1)).to eq(["Body"])
      end
    end

    describe "item_cards" do
      it "returns cards for unknown items by default" do
        expect(pointer.item_cards)
          .to include(instance_of(Card), instance_of(Card))
      end

      it "does not return unknown items when `known_only` arg is true" do
        pointer.add_item "A"
        expect(pointer.item_cards(known_only: true)).to eq([Card["A"]])
      end

      it "sets the default type of cards when 'type' argument is set" do
        expect(pointer.item_cards(type: "Image").first.type_code).to eq(:image)
      end
    end

    describe "item_name" do
      it "returns the first item's name by default" do
        expect(pointer.first_name).to eq("Busy")
      end

      it "handles offsets" do
        expect(pointer.first_name(offset: 1)).to eq("Body")
      end
    end
  end

  describe "add_item" do
    let(:pointer) { Card.new name: "tp", type: "pointer" }

    it "add to empty ref list" do
      pointer.add_item "John"
      expect(pointer.content).to eq("John")
    end

    it "add to existing ref list" do
      pointer.content = "[[Jane]]"
      pointer.add_item "John"
      expect(pointer.content).to eq("Jane\nJohn")
    end
  end

  describe "drop_item" do
    let :pointer do
      Card.new name: "tp", type: "pointer", content: "[[Jane]]\n[[John]]"
    end

    it "remove the link" do
      pointer.drop_item "Jane"
      expect(pointer.content).to eq("John")
    end

    it "not fail on non-existent reference" do
      pointer.drop_item "Bigfoot"
      expect(pointer.content).to eq("Jane\nJohn")
    end

    it "remove the last link" do
      pointer.drop_item "John"
      pointer.drop_item "Jane"
      pointer.content.should == ""
    end
  end
end
