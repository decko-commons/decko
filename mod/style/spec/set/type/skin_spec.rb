# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Skin do
  let(:css)                    { "#box { display: block }"  }
  let(:compressed_css)         { "#box{display:block}\n"    }
  let(:changed_css)            { "#box { display: inline }" }
  let(:compressed_changed_css) { "#box{display:inline}\n"   }

  let! :skin do
    ensure_card "test skin", type: :skin, content: ""
  end

  let! :item do
    ensure_card "skin item", type: :css, content: css
  end

  let! :outputter do
    ensure_card "style with skin+*style",
                type: :pointer, content: "[[test skin]]"
  end

  context "when item added" do
    it "updates output of related machine card" do
      skin.name.card.add_item! item
      expect(outputter_file_content).to eq(compressed_css)
    end
  end

  context "when item changed", as_bot: true do
    it "updates output of related machine card" do
      skin.name.card.add_item! item
      item.name.card.update! content: changed_css

      expect(outputter_file_content).to eq(compressed_changed_css)
    end
  end

  def outputter_file_content
    path = outputter.asset_output_path
    File.read(path)
  end
end
