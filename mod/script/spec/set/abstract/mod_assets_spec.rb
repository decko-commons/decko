# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::ModAssets do
  let(:script) { Card[:mod_script_script] }

  it "has two groups" do
    expect(script.item_names)
      .to eq ["mod: script+*script+jquery", "mod: script+*script+decko"]
  end

  specify "core view" do
    expect_view(:core, card: script)
      .to include("mod_script+*script+decko")
      .and include("mod_script+*script+jquery")
  end

  specify "javascript_include_tag view" do
    expect_view(:javascript_include_tag, card: script).to include("<script src=").twice
  end

  it "updates assets" do
    card = Card["mod: script+*script"]
    card.update_asset_output
    card.make_asset_output_coded
    card.asset_outputcard.content.should eq(":mod_script_script_asset_output/assets.js")
    content = card.asset_output_card.file.file.read
    content.should include "// jquery3.js"
    content.should include "// decko.js.coffee"
  end
end
