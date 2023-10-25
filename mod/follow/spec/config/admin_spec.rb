RSpec.describe Card::Set::Type::Mod do
  specify "admin config of layout mod" do
    card = Card.fetch(:mod_follow)
    aggregate_failures do
      expect(card.settings).to eq %i[follow_fields follow]
      expect(card.configurations).to be_nil
      expect(card.cardtypes).to eq [["Template", %i[notification_template]]]
    end
  end
end
