# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Setting do
  def card_subject
    :read.card
  end

  check_views_for_errors
  check_views_for_errors format: :data
  check_views_for_errors format: :json, views: :molecule

  describe "rule_help view" do
    it "renders links (ie, not in template mode)" do
      expect_view(:rule_help).to have_tag("div.alert.alert-info.rule-instruction") do
        with_tag "a.known-card", text: "Set", with: { href: "/Set" }
      end
    end
  end
end
