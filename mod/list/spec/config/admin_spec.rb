RSpec.describe Card::Set::Type::Mod do
  specify "admin config of list mod" do
    card = Card.fetch(:mod_list)
    aggregate_failures do
      expect(card.settings).to eq %i[content_options content_option_view]
      expect(card.configurations).to be_nil
      expect(card.cardtypes).to eq [["Organize", %i[list pointer nest_list link_list]]]
    end
  end
end
