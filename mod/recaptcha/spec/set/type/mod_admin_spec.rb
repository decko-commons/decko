RSpec.describe Card::Set::Type::Mod do
  specify "admin config of recaptcha mod" do
    card = Card.fetch(:mod_recaptcha)
    aggregate_failures do
      expect(card.settings).to eq %i[captcha]
      expect(card.configurations).to eq("basic" => ["recaptcha_settings"])
      expect(card.cardtypes).to be_nil
    end
  end
end
