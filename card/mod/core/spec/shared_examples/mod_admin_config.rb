RSpec.shared_examples "mod admin config" do |mod_codename, expected_settings, expected_configurations, expected_cardtypes|
  card = Card.fetch(mod_codename)
  specify "admin.yml of #{mod_codename} loaded correctly"  do
    aggregate_failures do
      expect(card.settings).to eq expected_settings
      expect(card.configurations).to eq expected_configurations
      expect(card.cardtypes).to eq expected_cardtypes
    end
  end
end