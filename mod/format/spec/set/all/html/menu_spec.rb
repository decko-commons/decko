# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::Html::Menu do
  check_html_views_for_errors

  def edit_menu edit=nil
    args = edit ? { edit: edit } : {}
    format_subject.render_menu args
  end

  describe "menu view" do
    example "when default" do
      expect(edit_menu)
        .to have_tag("div.card-menu.nodblclick._show-on-hover") do
        with_tag "a.edit-link", with: { "data-modal-class": "modal-lg",
                                        href: "/A?view=edit" }
      end
    end

    example "when voo.edit = :standard" do
      expect(edit_menu(:standard)).to eq(edit_menu)
    end

    example "when voo.edit = :full" do
      expect(edit_menu(:full))
        .to have_tag("a.edit-link", with: { href: "/A?view=bridge" })
    end

    example "when voo.edit = :inline" do
      expect(edit_menu(:inline))
        .to have_tag("a.edit-link", with: { href: "/A?view=edit_inline" })
    end
  end
end
