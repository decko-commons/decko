RSpec.describe "help mod" do
  specify "admin config" do
    card = Card.fetch(:mod_help)
    aggregate_failures do
      expect(card.settings).to eq %i[help guide]
      expect(card.configurations).to be_nil
      expect(card.cardtypes).to be_nil
    end
  end
end
