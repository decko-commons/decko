RSpec.shared_examples("mod admin config") do
  |mod_codename, settings, configurations, cardtypes|
  card = Card.fetch(mod_codename)
  specify "admin.yml of #{mod_codename} loaded correctly"  do
    aggregate_failures do
      expect(card.settings).to eq settings
      expect(card.configurations).to eq configurations
      expect(card.cardtypes).to eq cardtypes
    end
  end
end
