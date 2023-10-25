RSpec.describe Card::Set::Type::Mod do
  specify "admin config of edit mod" do
    card = Card.fetch(:mod_edit)
    aggregate_failures do
      expect(card.settings).to eq %i[input_type]
      expect(card.configurations).to be_nil
      expect(card.cardtypes).to be_nil
    end
  end
end
