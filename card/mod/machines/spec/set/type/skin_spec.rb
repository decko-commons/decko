# -*- encoding : utf-8 -*-

describe Card::Set::Type::Skin do
  let(:css)                    { "#box { display: block }"  }
  let(:compressed_css)         { "#box{display:block}\n"    }
  let(:changed_css)            { "#box { display: inline }" }
  let(:compressed_changed_css) { "#box{display:inline}\n"   }
  let(:new_css)                { "#box{display: none }\n"   }
  let(:compressed_new_css)     { "#box{display:none}\n"   }

  it_behaves_like "machine input"  do
    let(:create_machine_input_card) do
      Card.gimme! "test skin input", type: :css, content: css
    end
    let(:create_another_machine_input_card) do
      Card.gimme! "more skin input", type: :css, content: css
    end
    let(:create_machine_card) do
      Card.gimme! "style with skin machine+*style", type: :pointer
    end
    let(:card_content) do
      { in:           css,         out:     compressed_css,
        changed_in:   changed_css, changed_out: compressed_changed_css }
    end
  end

  context "when item added" do
    it "updates output of related machine card" do
      # item = Card.gimme! "skin item", type: :css, content: css
      skin = Card.gimme! "test skin supplier", type: :skin, content: ""
      item = Card.gimme! "skin item", type: :css, content: css
      machine = Card.gimme! "style with skin machine+*style",
                            type: :pointer, content: "[[test skin supplier]]"
      skin << item
      skin.putty
      updated_machine = Card.gimme machine.name
      path = updated_machine.machine_output_path
      expect(File.read(path)).to eq(compressed_css)
    end
  end

  context "when item changed" do
    it "updates output of related machine card" do
      skin = Card.gimme! "test skin supplier", type: :skin, content: ""
      item = Card.gimme! "skin item", type: :css, content: css
      machine = Card.gimme! "style with skin machine+*style",
                            type: :pointer, content: "[[test skin supplier]]"
      skin << item
      skin.putty

      Card::Auth.as_bot do
        Card["skin_item"].update_attributes content: changed_css
        machine.machine_output_url
        Card["skin_item"].update_attributes content: new_css
      end
      updated_machine = Card.gimme machine.name
      path = updated_machine.machine_output_path
      expect(File.read(path)).to eq(compressed_new_css)
      expect(updated_machine.machine_input_card.content)
        .to include("[[skin item]]")
      expect(Card.search(link_to: "skin item"))
        .to include(updated_machine.machine_input_card)
    end
  end
end
