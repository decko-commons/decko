# -*- encoding : utf-8 -*-

shared_examples_for "asset inputter" do |_args|
  before do
    # Cardio.config.compress_assets = true
  end

  let! :asset_outputter do
    f = create_asset_outputter_card
    f.add_item! input.name
    f
  end

  let :input do
    create_asset_inputter_card.name.card
  end

  let :more_input do
    create_another_asset_inputter_card
  end

  context "when updated" do
    it "updates output of related asset outputter" do
      input.name.card.update! content: card_content[:changed_in]
      expect(outputter_file_content).to eq(card_content[:changed_out])
    end
  end

  context "when removed" do
    it "updates asset output card", as_bot: true do
      input.name.card.delete!
      expect(outputter_file_content).to eq("")
    end
  end

  it "delivers asset input" do
    expect(input.asset_input).to eq(card_content[:out])
  end

  context "when added" do
    it "updates output of related asset outputter" do
      asset_outputter.add_item! more_input
      out = card_content[:added_out] || ([card_content[:out]] * 2).join("\n")
      expect(outputter_file_content).to eq(out)
    end
  end

  def outputter_file_content
    path = asset_outputter.name.card.asset_output_path
    File.read(path)
  end

  # context "a non-existent card was added as item and now created" do
  #   it "updates #{args[:that_produces]} file", as_bot: true do
  #     asset_outputter.update! content: "[[non-existent input]]"
  #     Card.ensure name: "non-existent input",
  #                 type: args[:that_produces],
  #                 content: card_content[:changed_in]
  #     out = card_content[:changed_out].gsub(input.name, "non-existent input")
  #     expect(read_asset_output).to eq(out)
  #   end
  # end
end
