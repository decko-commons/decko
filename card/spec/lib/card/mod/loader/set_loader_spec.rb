# -*- encoding : utf-8 -*-

RSpec.describe Card::Mod::Loader::SetLoader do
  let(:mod_dirs) do
    path = File.expand_path "../../../../../support/test_mods", __FILE__
    Card::Mod::Dirs.new path
  end

  it 'initializes the load strategy' do
    expect(Card::Mod::LoadStrategy::Eval).to receive(:new).with(mod_dirs, instance_of(described_class))
    described_class.new(:eval, mod_dirs)
  end

  it "load mods" do
    described_class.new(:eval, mod_dirs).load
    expect(Card::Set.const_defined?("All::TestSet")).to be_truthy
    expect(Card.take.test_method).to eq "works"
  end
end
