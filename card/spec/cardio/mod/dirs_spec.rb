RSpec.describe Cardio::Mod::Dirs do
  xit "loads mods from Modfile" do
    path = File.expand_path __dir__
    tg = described_class.new path
    expect(tg.mods.map(&:name)).to include("mod1", "mod2")
  end
end
