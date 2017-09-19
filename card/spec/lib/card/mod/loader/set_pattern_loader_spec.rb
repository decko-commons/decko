# -*- encoding : utf-8 -*-

RSpec.describe Card::Mod::Loader::SetPatternLoader do
  let(:mod_dirs) do
    path = File.expand_path "../../../../../support/test_mods", __FILE__
    puts path
    Card::Mod::Dirs.new path
  end

  it 'initializes the load strategy' do
    expect(Card::Mod::LoadStrategy::Eval).to receive(:new).with(mod_dirs, instance_of(described_class))
    described_class.new :eval, mod_dirs
  end

  it "load mods" do
    described_class.new(:eval, mod_dirs).load
    expect(Card::Set.const_defined?("TestPattern")).to be_truthy
  end
end
