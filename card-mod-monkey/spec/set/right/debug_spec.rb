# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Right::Debug do
  describe "core view" do
    let(:core) { render_card :core, name: "A+*debug" }

    it "has a table" do
      Card::Auth.as_bot { assert_view_select core, "table" }
    end
  end
end
