# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::RichHtml::Menu do

  check_views_for_errors :edit_link, :full_page_link

  def edit_menu edit=nil
    args = edit ? { edit: edit } : {}
    format_subject.render_menu args
  end

  describe "menu view" do
    context "when default" do
      specify do
        expect(edit_menu)
          .to have_tag("div.card-menu.nodblclick._show-on-hover") do
            with_tag "a.edit-link", with: { "data-modal-class":"modal-lg",
                                            href: "/A?view=edit" }
        end
      end
    end

    context "when voo.edit = :standard" do
      specify do
        expect(edit_menu(:standard))
          .to have_tag("a.edit-link", with: { "data-modal-class":"modal-lg" })
      end
    end

    context "when voo.edit = :full" do
      specify do
        expect(edit_menu(:full))
          .to have_tag("a.edit-link", with: { href: "/A?view=bridge" })
      end
    end

    context "when voo.edit = :inline" do
      specify do
        expect(edit_menu(:inline))
          .to have_tag("a.edit-link", with: { href: "/A?view=edit_in_place"})
      end
    end
  end
end