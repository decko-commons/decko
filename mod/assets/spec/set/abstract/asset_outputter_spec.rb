# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::AssetOutputter do
  describe "#make_asset_output_coded" do
    it "creates coded file" do
      mod_path = Cardio::Mod.dirs.path "script"
      path = File.join mod_path,
                       "data", "files", "mod_script_script_decko_machine_output", "file.js"
      expect(File).to be_exist(path),
                      "Decko should be shipped with generated script files"

      File.delete path
      Card[:script_group__decko, :asset_output].delete

      card = Card[:script_group__decko]
      # card.update_asset_output
      card.make_asset_output_coded :script
      expect(File).to be_exist(path)
    end
  end
end
