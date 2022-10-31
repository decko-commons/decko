RSpec.describe Card::Set::TypePlusRight::Set::Style do
  #  describe "#delet"
  #  it "deletes tempfile"
  let(:css)                    { "#box { display: block }"  }
  let(:compressed_css)         { "#box{display:block}\n"    }
  let(:changed_css)            { "#box { display: inline }" }
  let(:compressed_changed_css) { "#box{display:inline}\n"   }
  let(:new_css)                { "#box{ display: none}\n"   }
  let(:compressed_new_css)     { "#box{display:none}\n"   }

  it_behaves_like "asset outputter", that_produces: :css do
    let(:asset_outputter_card) do
      Card.ensure name: "test my style+*self+*style", type: :list, content: ""
    end
    let(:asset_inputter_card) do
      Card.ensure name: "test css", type: :css, content: css
    end
    let(:invalid_inputter_card) do
      Card.ensure name: "invalid test css", type: :plain_text, content: css
    end
    let(:card_content) do
      { in: css,                         out: compressed_css,
        changed_in: changed_css, changed_out: compressed_changed_css,
        new_in: new_css,             new_out: compressed_new_css }
    end
  end

  describe "#ok_item_types" do
    it "catches invalid item type" do
      card = Card.create name: "A+*self+*style", content: "B"
      expect(card.errors[:content])
        .to include("B has an invalid type: RichText. "\
                    "Allowed types: CSS, SCSS, Skin, and Bootswatch skin.")
    end

    it "allows valid item types" do
      card = Card.create name: "A+*self+*style", content: "Sample CSS"
      expect(card.errors[:content]).to be_empty
    end
  end
end
