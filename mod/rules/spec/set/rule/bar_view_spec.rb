# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Rule::BarView do
  def card_subject
    Card.fetch("*read+*right+*input type", new: {})
  end

  check_views_for_errors

  it "renders setting view for a *input type rule", as_bot: true do
    expect_view("rule_edit").to have_tag "div.modal" do
      with_tag "div.rule-section", count: 2
    end
  end
end
