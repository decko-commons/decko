# -*- encoding : utf-8 -*-

shared_examples_for "asset outputter" do |args|
  let(:filetype)  { args[:that_produces] }

  describe "update_asset_output" do
    before do
      asset_outputter_card.update_asset_output
    end

    it "has +asset_output card" do
      expect(asset_outputter_card.asset_output_card).to be_real
    end

    it "generates #{args[:that_produces]} file" do
      expect(asset_outputter_card.asset_output_path).to match(/\.#{filetype}$/)
    end
  end

  describe "event update_asset_output_file" do
    before do
      asset_outputter_card.add_item! asset_inputter_card
    end

    it "creates file with supplied content" do
      path = asset_outputter_card.asset_output_path
      expect(File.read(path)).to eq(card_content[:out])
    end
  end

  describe "event validate_asset_inputs" do
    it "doesn't allow invalid inputter cards" do
      expect { asset_outputter_card.add_item! invalid_inputter_card }
        .to raise_error(ActiveRecord::RecordInvalid, /not a valid asset input card/)
    end
  end
end
