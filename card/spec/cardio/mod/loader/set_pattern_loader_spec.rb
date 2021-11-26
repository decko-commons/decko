# -*- encoding : utf-8 -*-

RSpec.describe Cardio::Mod::Loader::SetPatternLoader do
  let(:mod_dirs) do
    path = File.expand_path "../../../support/test_mods", __dir__
    puts path
    Cardio::Mod::Dirs.new path
  end

  # FIXME: These tests can break others because they leave bogus set patterns in place

  xit "initializes the load strategy" do
    expect(Cardio::Mod::LoadStrategy::Eval)
      .to receive(:new).with(instance_of(described_class))
    described_class.new load_strategy: :eval, mod_dirs: mod_dirs
  end

  xit "load mods" do
    described_class.new(load_strategy: :eval, mod_dirs: mod_dirs).load
    expect(Card::Set).to be_const_defined("TestPattern")
  end
end
