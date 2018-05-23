describe Card::Set::Abstract::Pointer do
  let(:pointer) do
    Card.create! name: "tp", type_id: Card::PointerID,
                 content: "[[item1]]\n[[item2]]"
  end

  def pointer_update content
    -> { Card["tp"].update_attributes! content: content }
  end

  describe "#added_item_names" do
    it "recognizes added items" do
      Card::Auth.as_bot do
        pointer
        in_stage(:finalize,
                 on: :save,
                 for: "tp",
                 trigger: pointer_update("[[item1]]\n[[item2]]\n[[item3]]")) do
          expect(added_item_names).to contain_exactly "item3"
        end
      end
    end

    it "ignores order" do
      Card::Auth.as_bot do
        pointer
        in_stage :finalize,
                 on: :save,
                 trigger: pointer_update("[[item2]]\n[[item1]]") do
          expect(added_item_names).to eq []
        end
      end
    end
  end

  describe "#dropped_item_names" do
    it "recognizes dropped items" do
      Card::Auth.as_bot do
        pointer
        in_stage :finalize,
                 on: :save,
                 trigger: pointer_update("[[item1]]") do
          expect(dropped_item_names).to eq ["item2"]
        end
      end
    end

    it "ignores order" do
      Card::Auth.as_bot do
        pointer
        in_stage :finalize,
                 on: :save,
                 trigger: pointer_update("[[item2]]\n[[item1]]") do
          expect(dropped_item_names).to eq []
        end
      end
    end
  end

  describe "#changed_item_names" do
    it "recognizes changed items" do
      Card::Auth.as_bot do
        pointer
        in_stage :finalize,
                 on: :save,
                 trigger: pointer_update("[[item1]]\n[[item3]]") do
          expect(changed_item_names.sort).to eq %w[item2 item3]
        end
      end
    end
  end

  describe "#standardize_item" do
    it "handles unlinked items" do
      pointer.update_attributes! content: "bracketme"
      expect(pointer.content).to eq("[[bracketme]]")
    end

    it "handles array on create" do
      pointer1 = Card.create! name: "pointer1",
                              type: "Pointer",
                              content: ["b1", "[[b2]]"]
      expect(pointer1.content).to eq("[[b1]]\n[[b2]]")
    end
  end
end
