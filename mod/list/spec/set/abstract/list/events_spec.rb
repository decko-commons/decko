describe Card::Set::Abstract::List do
  let(:pointer) do
    Card.create! name: "tp", type: :pointer, content: "[[item1]]\n[[item2]]"
  end

  def pointer_update content
    -> { Card["tp"].update! content: content }
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

  describe "#standardize_content" do
    it "handles unlinked items" do
      pointer.update! content: "nobrackets"
      expect(pointer.content).to eq("nobrackets")
    end

    it "handles array on create" do
      pointer1 = Card.create! name: "pointer1",
                              type: "Pointer",
                              content: ["b1", "[[b2]]"]
      expect(pointer1.content).to eq("b1\nb2")
    end

    it "handles arrays for fields" do
      create "super card", fields: { "a pointer" => { content: ["b1", "[[b2]]"],
                                                      type: :pointer } }
      expect_card("super card+a pointer").to have_db_content "b1\nb2"
    end
  end

  describe "event: validate_item_uniqueness" do
    def card_subject_name
      "stacks".card
    end

    it "adds an error when there are duplicate items" do
      card_subject.singleton_class.define_method(:validate_item_uniqueness?) { true }
      expect { card_subject.update! content: %w[horizontal horizontal vertical vertical] }
        .to raise_error /duplicate item names: horizontal and vertical/
    end
  end
end
