RSpec.describe "script mod" do
  specify "admin config" do
    card = Card.fetch(:mod_script)
    aggregate_failures do
      expect(card.settings).to eq %i[script]
      expect(card.configurations).to be_nil
      expect(card.cardtypes).to eq [["Scripting", %i[java_script coffee_script]], ["Asssets", %i[local_script_folder_group local_script_manifest_group]]]
    end
  end
end
