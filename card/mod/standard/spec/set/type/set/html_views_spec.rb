# -*- encoding : utf-8 -*-

describe Card::Set::Type::Set::HtmlViews do
  extend Card::SpecHelper::ViewHelper::ViewDescriber

  let(:sample_set) { Card.fetch("User+*type") }

  describe_views :all_rules, :grouped_rules, :recent_rules, :common_rules,
                 :field_related_rules, :set_label, :set_navbar, :rule_navbar do
    it "doesn't have errors" do
      expect(sample_set.format.render(view)).to lack_errors
    end
  end
end
