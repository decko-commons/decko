# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::Bridge do
  describe "edit_nests view" do
    it "shows editors for both absolute and relative nests" do
      card_subject.content = "{{absolute}} AND {{+relative}}"
      expect_view(:edit_nests).to have_tag "div.SELF-a" do
        with_tag "div.card-editor", with: { card_name: "absolute" }
        with_tag "div.card-editor", with: { card_name: "A+relative" }
      end
    end
  end

  check_views_for_errors :edit, :edit_buttons, :edit_name, :edit_type, :edit_rules,
                         :edit_structure, :edit_nests
end
