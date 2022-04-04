# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::ModAssets do
  let(:style) { Card[:mod_bootstrap, :style] }

  it "has three groups" do
    expect(style.item_names)
      .to eq ["mod: bootstrap+*style+group: bootstrap_decko",
              "mod: bootstrap+*style+group: libraries",
              "mod: bootstrap+*style+group: select2"]
  end

  specify "core view" do
    expect_view(:core, card: style)
      .to include("mod: bootstrap+*style+group: bootstrap_decko")
      .and include("mod: bootstrap+*style+group: libraries")
  end

  it "updates assets" do
    card = Card[:all, :style]
    # Card::Assets.refresh_assets
    Card["mod: bootstrap"].ensure_mod_asset_card :style
    # input = Card["mod: bootstrap+*style+asset input"]
    card.update_asset_output
    card.make_asset_output_coded
    content = card.asset_output_card.file.file.read

    content.should include "#forgot-password input#email" # from style_bootstrap_cards
    content.should include "font-family:fontAwesome;"     # from font-awesome
    content.should include "._rename-reference-confirm"   # from style_cards"
  end
end
