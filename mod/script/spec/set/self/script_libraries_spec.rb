# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::ScriptLibraries do
  subject { Card[:script_libraries] }

  it "loads ace.js" do
    # We use jquery-ui with selectable and autocomplete included.
    # All other additional stuff in jquery-ui is there because those two
    # depend on it.
    expect(subject.asset_file_cards.size).to eq 1
    expect(subject.asset_file_cards.first.name).to eq "library: script_ace.js"
  end

  specify "core view" do
    expect_view(:core, card: subject).to include "script_ace.js"
  end

  describe "include_tag view" do
    it "includes ace" do
       expect_view(:include_tag, card: subject).to eq('<script src=>')
    end
  end

end
