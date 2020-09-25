RSpec.describe Card::Mod do
  describe "gem_spec" do
    it "finds card mods" do
      expect(described_class.gem_spec("card-mod-defaults"))
        .to be_a(Gem::Specification)
    end
  end
end