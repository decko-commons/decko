RSpec.describe "captcha mod" do
  specify "admin config" do
    card = Card.fetch(:mod_recaptcha)
    aggregate_failures do
      expect(card.settings).to eq %i[captcha]
      expect(card.configurations).to eq({ "basic" => ["recaptcha_settings"] })
      expect(card.cardtypes).to be_nil
    end
  end
end
