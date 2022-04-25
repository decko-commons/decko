# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::ModAssets do
  let(:script) { %i[mod_script script].card }

  it "has two groups" do
    expect(script.item_names)
      .to eq ["mod: script+*script+group: jquery", "mod: script+*script+group: decko"]
  end

  specify "core view" do
    expect_view(:core, card: script)
      .to include("+group: decko")
      .and include("+group: jquery")
  end

  specify "javascript_include_tag view" do
    expect_view(:javascript_include_tag, card: script).to include("<script src=").thrice
  end

  it "updates assets" do
    card = Card["mod: script+*script"]
    card.update_asset_output
    card.make_asset_output_coded
    card.asset_output_card.content.should eq(":mod_script_script_asset_output/script.js")
    content = card.asset_output_card.file.file.read
    content.should include "// decko.js.coffee"
  end
end
