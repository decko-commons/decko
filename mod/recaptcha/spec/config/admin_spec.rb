RSpec.describe "captcha mod" do
  specify "admin config" do
    card = Card.fetch(:mod_captcha)
    aggregate_failures do
      expect(card.settings).to eq %i[captcha]
      expect(card.configurations).to be_nil
      expect(card.cardtypes).to be_nil
    end
  end
end
