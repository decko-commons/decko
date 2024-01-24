RSpec.shared_examples "mod admin config" do |codename, settings, configs, cardtypes|
  card = codename.card
  specify "admin.yml of #{codename} loaded correctly"  do
    aggregate_failures do
      expect(card.settings).to eq settings
      expect(card.configurations).to eq configs
      expect(card.cardtypes).to eq cardtypes
    end
  end
end
