# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::Machine do
  describe "#make_machine_output_coded" do
    it "creates coded file" do
      Card[:all, :script].make_machine_output_coded
      mod_path = Cardio::Mod.dirs.path "machines"
      path = File.join mod_path, "file", "all_script_machine_output", "file.js"
      expect(File.exist?(path)).to be_truthy
    end
  end
  
  example "machine config" do
    card = Card["A"].with_set Card::Set::Abstract::Machine
    expect(card).to respond_to :engine_input
  end
end
