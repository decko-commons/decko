# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::NestEditor do
  describe "view: nest_image" do
    check_html_views_for_errors

    it "finds next new image card", as_bot: true do
      create "42+image1"
      rendered = Card["42"].format.render(:nest_image)
      expect(rendered).to have_tag "span.card-title", with: { title: "42+sdfimage2" }
    end
  end
end
