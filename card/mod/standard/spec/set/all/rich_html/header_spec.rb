RSpec.describe Card::Set::All::RichHtml::Header do
  check_html_views_for_errors

  describe "closed view" do
    it "has title toggle by default" do
      expect_view(:closed).to have_tag "div.d0-card-header.card-header" do
        with_tag "a.toggler.slotter", with:  { href: "/A?view=open" } do
          without_tag "a.open-icon.slotter"
          with_tag "span.card-title", "A"
        end
      end
    end

    context "with show: title_link" do
      it "has icon toggle and no title toggle" do
        rendered = render_card_with_args :closed, { name: "A" }, {}, show: :title_link
        expect(rendered).to have_tag "div.d0-card-header.card-header" do
          with_tag "div.d0-card-header-title" do
            with_tag "a.toggle-open.slotter", with: { href: "/A?view=open" } do
              with_tag :i, "expand_more"
            end
            with_tag "a", with:  { href: "/A" }, without: { class: "toggler" } do
              with_tag "span.card-title", "A"
            end
          end
        end
      end
    end

    context "with show: icon_toggle" do
      it "has icon toggle and no title toggle" do
        rendered = render_card_with_args :closed, { name: "A" }, {}, show: :icon_toggle
        expect(rendered).to have_tag "div.d0-card-header.card-header" do
          with_tag "div.d0-card-header-title" do
            with_tag "a.toggle-open.slotter", with: { href: "/A?view=open" } do
              with_tag :i, "expand_more"
            end

            without_tag "a.toggle-open", with:  { href: "/A" }
            with_tag "span.card-title", "A"
          end
        end
      end
    end
  end

  describe "titled view" do
    it "has no title toggle" do
      expect_view(:titled)
        .to have_tag "div.d0-card-header", without: { class: "card-header" } do
        without_tag "a.toggler"
        with_tag "span.card-title", "A"
      end
    end
  end

  describe "open view" do
    it "has title toggle by default" do
      expect_view(:open).to have_tag "div.d0-card-header.card-header" do
        with_tag "a.toggler.slotter", with:  { href: "/A?view=closed" } do
          with_tag "span.card-title", "A"
        end
      end
    end

    context "with show: icon_toggle" do
      it "has icon toggle and no title toggle" do
        rendered = render_card_with_args :open, { name: "A" }, {}, show: :icon_toggle
        expect(rendered).to have_tag "div.d0-card-header.card-header" do
          with_tag "div.d0-card-header-title" do
            with_tag "a.toggle-closed.slotter", with: { href: "/A?view=closed" } do
              with_tag :i, "expand_less"
            end

            without_tag "a.toggle-closed", with:  { href: "/A" }
            with_tag "span.card-title", "A"
          end
        end
      end
    end
  end
end
