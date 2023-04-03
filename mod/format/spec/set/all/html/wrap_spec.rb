# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::Html::Wrap do
  context "with full wrapping" do
    it "adds extra css classes" do
      expect_view(:nest_rules, card: "A+*self")
        .to have_tag "div.card-slot._setting-list"
    end
  end
end
