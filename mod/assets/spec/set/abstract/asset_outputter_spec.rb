# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::AssetOutputter do
  describe "#make_asset_output_coded" do
    it "creates coded file" do
      mod_path = Cardio::Mod.dirs.path "format"
      path = File.join mod_path,
                       "data", "files", "mod_format_script_asset_output", "file.js"
      expect(File).to be_exist(path),
                      "Decko should be shipped with generated script file. " \
                      "Couldn't find #{path}"

      File.delete path
      Card[:mod_format, :script, :asset_output].delete

      card = Card[:mod_format, :script]
      card.update_asset_output
      card.make_asset_output_coded
      expect(File).to be_exist(path)
    end
  end
end
