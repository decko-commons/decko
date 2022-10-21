# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::ReferenceEditor::NestImage do
  check_views_for_errors

  describe "view: nest_image" do
    it "finds next new image card", as_bot: true do
      Card.ensure name: "image01"
      rendered = Card["A"].format.render(:nest_image)
      expect(rendered).to have_tag "#file_card_name", with: { value: "image02" }
    end
  end
end
