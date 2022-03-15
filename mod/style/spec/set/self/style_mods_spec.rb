# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::StyleMods do
  describe "dependent_asset_inputters" do
    it "finds active theme" do
      expect(card_subject.dependent_asset_inputters).to eq [:yeti_skin.card]
    end
  end
end
