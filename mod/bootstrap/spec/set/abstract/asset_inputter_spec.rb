# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::AssetInputter do
  specify "asset input" do
    card = Card[:mod_bootstrap, :style]
    card.update_asset_input
    expect(card.asset_input).to include ".dropdown-menu"
  end
end
