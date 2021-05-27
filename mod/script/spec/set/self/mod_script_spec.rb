# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::ModAssets do
  subject { Card[:mod_script_script] }

  it "has two groups" do
    expect(subject.item_names).to eq ["mod: script+*script+jquery", "mod: script+*script+decko"]
  end

  specify "core view" do
    expect_view(:core, card: subject).to include("mod_script+*script+decko")
                                           .and include("mod_script+*script+jquery")
  end

  specify "javascript_include_tag view" do
    expect_view(:javascript_include_tag, card: subject).to include('<script src=').twice
  end

end
