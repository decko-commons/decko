RSpec.describe Card::Set::Type::Mod do
  specify "admin config of script mod" do
    card = Card.fetch(:mod_script)
    aggregate_failures do
      expect(card.settings).to eq %i[script]
      expect(card.configurations).to be_nil
      expect(card.cardtypes)
        .to eq [["Scripting", %i[java_script coffee_script]],
                ["Assets", %i[local_script_folder_group local_script_manifest_group]]]
    end
  end
end
