RSpec.describe "edit mod" do
  specify "admin config" do
    card = Card.fetch(:mod_edit)
    aggregate_failures do
      expect(card.settings).to eq %i[input_type]
      expect(card.configurations).to be_nil
      expect(card.cardtypes).to be_nil
    end
  end
end
