RSpec.describe "list mod" do
  specify "admin config" do
    card = Card.fetch(:mod_list)
    aggregate_failures do
      expect(card.settings).to eq %i[content_options content_option_view]
      expect(card.configurations).to be_nil
      expect(card.cardtypes).to eq %i[list pointer nest_list link_list]
    end
  end
end
