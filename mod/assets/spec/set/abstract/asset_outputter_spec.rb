# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::AssetOutputter do
  describe "#make_asset_output_coded" do
    it "creates coded file" do
      mod_path = Cardio::Mod.dirs.path "defaults"
      path = File.join mod_path,
                       "data", "files", "all", "script", "asset_output", "file.js"
      expect(File).to be_exist(path),
                      "Decko should be shipped with generated script file. " \
                      "Couldn't find #{path}"

      File.delete path
      Card[:all, :script, :asset_output].delete

      card = Card[:all, :script]
      card.update_asset_output
      card.make_asset_output_coded
      expect(File).to be_exist(path)
    end
  end
end
