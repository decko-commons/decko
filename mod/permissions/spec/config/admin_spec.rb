RSpec.describe Card::Set::Type::Mod do
  specify "admin config of permissions mod" do
    card = Card.fetch(:mod_permissions)
    aggregate_failures do
      expect(card.settings).to eq %i[create read update delete]
      expect(card.configurations).to be_nil
      expect(card.cardtypes).to be_nil
    end
  end
end
