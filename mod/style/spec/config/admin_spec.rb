RSpec.describe "style mod" do
  specify "admin config" do
    card = Card.fetch(:mod_style)
    aggregate_failures do
      expect(card.settings).to eq %i[style]
      expect(card.configurations).to be_nil
      expect(card.cardtypes).to be_nil
    end
  end
end
