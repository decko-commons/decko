# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::ReferenceEditor::NestImage do
  describe "view: nest_image" do
    check_html_views_for_errors

    it "finds next new image card", as_bot: true do
      ensure_card "A+image01"
      rendered = Card["A"].format.render(:nest_image)
      expect(rendered).to have_tag "span.card-title", with: { title: "A+image02" }
    end
  end
end
