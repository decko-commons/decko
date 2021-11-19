# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::ModAssets do
  let(:style) { Card[:mod_bootstrap, :style] }

  it "has two groups" do
    expect(style.item_names)
      .to eq ["mod: bootstrap+*style+group: bootstrap_decko",
              "mod: bootstrap+*style+group: libraries"]
  end

  specify "core view" do
    expect_view(:core, card: script)
      .to include("mod: bootstrap+*style+group: bootstrap_decko")
      .and include("mod: bootstrap+*style+group: libraries")
  end

  it "updates assets" do
    card = Card[:all, :style]
    # Card::Assets.refresh_assets
    Card["mod: bootstrap"].ensure_mod_style_card
    # input = Card["mod: bootstrap+*style+asset input"]
    card.update_asset_output
    card.make_asset_output_coded
    content = card.asset_output_card.file.file.read
    content.should include "// style_bootstrap_cards.scss"
    content.should include "// font_awesome.css"
    content.should include "// style_cards.scss"
  end
end
