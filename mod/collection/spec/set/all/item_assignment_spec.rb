RSp ec.describe Card::Set::All::ItemAssignment do
  def card_subject
    "stacks".card
  end

  let(:pointer) { Card.new type: "Pointer", content: "[[Busy]]\n[[Body]]" }

  specify "#add_item!" do
    card_subject.add_item! "A"
    expect(card_subject.item_names).to eq %w[horizontal vertical A]
  end

  specify "#drop_item!" do
    card_subject.drop_item! "vertical"
    expect(card_subject.item_names).to eq %w[horizontal]
  end

  specify "#replace_item" do
    card_subject.replace_item "vertical", "A"
    expect(card_subject.item_names).to eq %w[horizontal A]
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
