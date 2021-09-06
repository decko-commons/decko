# -*- encoding : utf-8 -*-

shared_examples_for "asset_outputter" do |args|
  let(:filetype)  { args[:that_produces] }

  context "machine is run" do
    before do
      asset_outputter.update_file_output
    end
    it "has +machine_output card" do
      expect(asset_outputter.asset_output_card).to be_real
    end

    it "generates #{args[:that_produces]} file" do
      expect(asset_outputter.asset_output_path).to match(/\.#{filetype}$/)
    end
  end
end

shared_examples_for "content machine" do |args|
  let(:filetype) { args[:that_produces] }

  it_behaves_like "machine", args do
    let(:machine) { machine_card }
  end

  context "+machine_input card" do
    it "points to self" do
      Card::Auth.as_bot do
        machine_card.update_input_card
      end
      expect(machine_card.input_item_cards).to eq([machine_card])
    end
  end

  context "+machine_output card" do
    it "creates file with supplied content" do
      path = machine_card.machine_output_path
      expect(File.read(path)).to eq(card_content[:out])
    end

    it "updates #{args[:that_produces]} file when content is changed" do
      changed_factory = machine_card
      changed_factory.putty content: card_content[:changed_in]
      changed_path = changed_factory.machine_output_path
      expect(File.read(changed_path)).to eq(card_content[:changed_out])
    end
  end
end


