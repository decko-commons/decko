# -*- encoding : utf-8 -*-

shared_examples_for "asset inputter" do # |args|
  let :input do
    create_machine_input_card
  end

  let! :asset_outputter do
    f = create_asset_outputter_card
    f.add_item! input
    f
  end

  let :more_input do
    moreinput = create_another_asset_inputter_card
    moreinput
  end

  context "when removed" do
    it "triggers an asset output of related asset outputter" do
      machine
      Card::Auth.as_bot { input.delete! }
      ca = Card.gimme machine.name
      expect(ca.machine_input_card.item_cards).to eq([])
    end

    it "updates output of machine card" do
      machine
      Card::Auth.as_bot { input.delete! }
      f = Card.gimme machine.name
      path = f.machine_output_path
      expect(File.read(path)).to eq("")
    end
  end

  it "delivers machine input" do
    expect(input.machine_input).to eq(card_content[:out])
  end

  context "when updated" do
    it "updates output of related machine card" do
      input.putty content: card_content[:changed_in]
      updated_machine = Card.gimme machine.name
      path = updated_machine.machine_output_path
      expect(File.read(path)).to eq(card_content[:changed_out])
    end
  end

  context "when added" do
    it "updates output of related machine card" do
      if machine.is_a? Card::Set::Type::Pointer
        machine << more_input
        machine.putty
        updated_machine = Card.gimme machine.name
        path = updated_machine.machine_output_path
        out = card_content[:added_out] || ([card_content[:out]] * 2).join("\n")
        expect(File.read(path)).to eq(out)
      end
    end
  end
end
