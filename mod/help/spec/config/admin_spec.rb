RSpec.describe Card::Set::Type::Mod do
  specify "admin config of help mod" do
    card = Card.fetch(:mod_help)
    aggregate_failures do
      expect(card.settings).to eq %i[help guide]
      expect(card.configurations).to be_nil
      expect(card.cardtypes).to be_nil
    end
  end
end
