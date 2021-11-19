# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self do
  specify "asset input" do
    card = Card[:mod_bootstrap_style]
    card.update_asset_input
    expect(card.asset_input).to include ".navbox-form"
  end
end
