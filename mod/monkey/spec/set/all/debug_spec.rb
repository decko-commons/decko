# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::Debug do
  describe "view: debug" do
    it "has a table" do
      Card::Auth.as_bot { assert_view_select render_card(:debug, name: "A"), "table" }
    end
  end
end
