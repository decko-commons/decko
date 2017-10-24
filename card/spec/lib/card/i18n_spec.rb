# -*- encoding : utf-8 -*-

require "i18n/tasks"

RSpec.describe "I18n" do
  # Note: I18n::Tasks only knows how to function when run from root of Card GEM,
  # since it locates its configuration file and source to parse relative to this
  let(:i18n) { Dir.chdir(Cardio.gem_root) { I18n::Tasks::BaseTask.new } }
  let(:missing_keys) { Dir.chdir(Cardio.gem_root) { i18n.missing_keys } }
  let(:unused_keys) { Dir.chdir(Cardio.gem_root) { i18n.unused_keys } }

  it "does not have missing keys" do
    expect(missing_keys).to be_empty,
      "Missing #{missing_keys.leaves.count} i18n keys, to show them `cd` to " \
      "root of `card` gem and run `i18n-tasks missing`"
  end

  it "does not have unused keys" do
    pending
    expect(unused_keys).to be_empty,
      "#{unused_keys.leaves.count} unused i18n keys, to show them `cd` to " \
      "root of `card` gem and run `i18n-tasks unused`"
  end
end
