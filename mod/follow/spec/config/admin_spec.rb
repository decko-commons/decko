RSpec.describe "layout mod" do
  specify "admin config" do
    card = Card.fetch(:mod_layout)
    aggregate_failures do
      expect(card.settings).to eq %i[layout head]
      expect(card.configurations).to be_nil
      expect(card.cardtypes).to eq%i[notification_template]
    end
  end
end
