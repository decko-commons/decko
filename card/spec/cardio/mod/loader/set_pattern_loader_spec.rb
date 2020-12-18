# -*- encoding : utf-8 -*-

RSpec.describe Cardio::Mod::Loader::SetPatternLoader do
  let(:mod_dirs) do
    path = File.expand_path "../../../../support/test_mods", __FILE__
    puts path
    Cardio::Mod::Dirs.new path
  end

  it 'initializes the load strategy' do
    expect(Cardio::Mod::LoadStrategy::Eval).to receive(:new).with(mod_dirs, instance_of(described_class))
    described_class.new load_strategy: :eval, mod_dirs: mod_dirs
  end

  it "load mods" do
    described_class.new(load_strategy: :eval, mod_dirs: mod_dirs).load
    expect(Card::Set.const_defined?("TestPattern")).to be_truthy
  end
end
