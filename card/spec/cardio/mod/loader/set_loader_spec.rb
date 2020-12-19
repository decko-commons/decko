# -*- encoding : utf-8 -*-

RSpec.describe Cardio::Mod::Loader::SetLoader do
  # This test is screwing up other tests when running in tmpfiles mode.
  # Temporarily disabiling - EFM
  #
  #
  let(:mod_dirs) do
    path = File.expand_path "../../../../support/test_mods", __FILE__
    Cardio::Mod::Dirs.new path
  end

  # def resetting_load_strategy
  #   load_strategy = Cardio::Mod::LoadStrategy.current
  #   yield
  #   Cardio::Mod::LoadStrategy.current = load_strategy
  # end
  #
  # it 'initializes the load strategy' do
  #   resetting_load_strategy do
  #     expect(Cardio::Mod::LoadStrategy::Eval)
  #         .to receive(:new).with(mod_dirs, instance_of(described_class))
  #     described_class.new(load_strategy: :eval, mod_dirs: mod_dirs)
  #   end
  # end
  #
  # it "load mods" do
  #   resetting_load_strategy do
  #     described_class.new(load_strategy: :eval, mod_dirs: mod_dirs).load
  #     expect(Card::Set.const_defined?("All::TestSet")).to be_truthy
  #     Card::Set.process_base_modules
  #     expect(Card.take.test_method).to eq "method works"
  #   end
  # end
end
