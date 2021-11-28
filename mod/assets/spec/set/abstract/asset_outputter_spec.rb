# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::AssetOutputter do
  describe "#make_asset_output_coded" do
    it "creates coded file" do
      mod_path = Cardio::Mod.dirs.path "assets"
      path = File.join mod_path,
                       "data", "files", "mod_script_script_asset_output", "file.js"
      expect(File).to be_exist(path),
                      "Decko should be shipped with generated script file. " \
                      "Couldn't find #{path}"

      File.delete path
      Card[:mod_script, :script, :asset_output].delete

      card = Card[:mod_script, :script]
      card.update_asset_output
      card.make_asset_output_coded :assets
      expect(File).to be_exist(path)
    end
  end
end
