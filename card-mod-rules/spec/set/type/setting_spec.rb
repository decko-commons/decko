# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Setting do
  describe "rule_help view" do
    subject { Card[:read].format.render :rule_help }

    it "renders links (ie, not in template mode)" do
      is_expected.to have_tag("div.alert.alert-info.rule-instruction") do
        with_tag "a.known-card", text: "Set", with: { href: "/Set" }
      end
    end
  end
end
