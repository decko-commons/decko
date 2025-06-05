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
      .to include("group: bootstrap_decko")
      .and include("group: libraries")
  end

  it "updates assets" do
    card = Card[:all, :style]
    # Card::Assets.refresh
    Card["mod: bootstrap"].ensure_mod_asset_card :style
    # input = Card["mod: bootstrap+*style+asset input"]
    card.update_asset_output
    card.make_asset_output_coded
    content = card.asset_output_card.file.file.read

    content.should include ".api-key-top"    # from api mod
    content.should include ".invite-links a"  # from account mod
  end
end
