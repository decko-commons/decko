# -*- encoding : utf-8 -*-

describe Card::Set::Type::Set::HtmlViews do
  def card_subject
    Card.fetch("User+*type")
  end

  check_views_for_errors :all_rules, :grouped_rules, :recent_rules, :common_rules,
                         :field_related_rules, :set_label, :set_navbar, :rule_navbar
end
