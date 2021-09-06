shared_examples_for "asset pipeline" do |args|
  subject do
    asset_outputter_card
  end

  let(:filetype) { args[:that_produces] }

  it_behaves_like "asset_outputter", args do
    let(:asset_outputter) { asset_outputter_card }
  end

  describe "+asset_output card" do
    it "creates #{args[:that_produces]} file with supplied content" do
      path = subject.asset_output_path
      expect(File.read(path)).to eq(card_content[:out])
    end

    it "updates #{args[:that_produces]} file if item is changed" do
      asset_inputter_card.update! content: card_content[:changed_in]
      changed_path = subject.asset_output_path
      expect(File.read(changed_path)).to eq(card_content[:changed_out])
    end

    it "updates #{args[:that_produces]} file if item is added" do
      Card::Auth.as_bot do
        ca = ensure_card "pointer item", type: Card::SkinID, content: ""
        subject.items = [ca]
        ca.add_item! another_asset_inputter_card
        changed_path = subject.asset_output_path
        expect(File.read(changed_path)).to eq(card_content[:new_out])
      end
    end

    context "a non-existent card was added as item and now created" do
      it "updates #{args[:that_produces]} file" do
        Card::Auth.as_bot do
          subject.update! content: "[[non-existent input]]"
          ensure_card "non-existent input",
                      type: input_type,
                      content: card_content[:changed_in]
          changed_path = subject.asset_output_path
          input_name = asset_inputtercard.name
          out = card_content[:changed_out].gsub(input_name, "non-existent input")
          expect(File.read(changed_path)).to eq(out)
        end
      end
    end
  end
end
