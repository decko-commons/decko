RSpec.describe "content mod" do
  specify "admin config" do
    card = Card.fetch(:mod_content)
    aggregate_failures do
      expect(card.settings).to eq %i[structure default]
      expect(card.configurations).to be_nil
      expect(card.cardtypes).to be_nil
    end
  end
end
