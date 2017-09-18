# -*- encoding : utf-8 -*-

RSpec.describe Card::Mod::Loader::ModuleLoader::PatternLoader do
  let(:mod_dirs) do
    path = File.expand_path "../../../../../../support/test_mods", __FILE__
    puts path
    Card::Mod::Dirs.new path
  end

  it 'initializes the load strategy with the right module type and module template' do
    expect(Card::Mod::LoadStrategy::Eval)
      .to receive(:new).with(
        mod_dirs, :set_pattern,
        Card::Mod::Loader::ModuleTemplate::PatternModule)
    described_class.new mod_dirs, load_strategy: :eval
  end

  it "load mods" do
    described_class.new(mod_dirs).load
    expect(Card::Set.const_defined?("TestPattern")).to be_truthy
  end
end
