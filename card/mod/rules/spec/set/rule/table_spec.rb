# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Rule::Table do
  def card_subject
    Card.fetch("*read+*right+*input", new: {})
  end

  check_html_views_for_errors

  it "renders setting view for a *input rule", as_bot: true do
    expect_view("open_rule").to have_tag "div.modal" do
      with_tag "div.rule-section", count: 2
    end
  end
end
