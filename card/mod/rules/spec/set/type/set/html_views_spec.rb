# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Set::HtmlViews do
  def card_subject
    Card.fetch("User+*type")
  end

  check_html_views_for_errors

  it "renders setting table for a right set" do
    expect_view("open", card: "*read+*right")
      .to have_tag "div", with: { id: "Xread-Xright-open-view" } do
      with_tag "form", with: { role: "filter" }
      with_tag "table" do
        with_tag "tr", with: { id: "Xread-Xright-Xcreate-rule_row-view" } do
          with_tag "td", "create"
          with_tag "td", "Administrator"
        end
      end
    end
  end
end
