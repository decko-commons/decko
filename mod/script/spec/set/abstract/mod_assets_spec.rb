# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::ModAssets do
  let(:script) { %i[mod_format script].card }

  it "has two groups" do
    expect(script.item_names)
      .to eq ["mod: format+*script+group: jquery", "mod: format+*script+group: decko"]
  end

  specify "core view" do
    expect_view(:core, card: script)
      .to include("group: decko")
      .and include("group: jquery")
  end

  specify "javascript_include_tag view" do
    expect_view(:javascript_include_tag, card: script).to include("<script src=").thrice
  end

  it "updates assets" do
    card = Card["mod: format+*script"]
    card.update_asset_output
    card.make_asset_output_coded
    expect(card.asset_output_card.content)
      .to eq(":mod_format+:script+:asset_output/format.js")
    expect(card.asset_output_card.file.file.read)
      .to include "// decko.js.coffee"
  end
end
