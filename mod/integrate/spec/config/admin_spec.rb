RSpec.describe Card::Set::Type::Mod do
  specify "admin config of integrate mod" do
    card = Card.fetch(:mod_integrate)
    aggregate_failures do
      expect(card.settings).to eq %i[on_create on_update on_delete]
      expect(card.configurations).to be_nil
      expect(card.cardtypes).to be_nil
    end
  end
end
