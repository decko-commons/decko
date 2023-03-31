RSpec.describe Card::Set::All::Html::Header do
  check_views_for_errors

  def view_with_show view, show
    render_card_with_args view, { name: "A" }, {}, { show: show }
  end

  let(:header_tag) { "div.d0-card-header.card-header" }

  def with_toggle_open binding
    binding.with_tag "a.toggle-open.slotter", with: { href: "/A?view=open" } do
      with_tag :i, "expand_more"
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

  # describe "open view" do
  #   it "has title toggle by default" do
  #     expect_view(:open).to have_tag(header_tag) do
  #       with_tag "a.toggler.slotter", with:  { href: "/A?view=closed" } do
  #         with_tag "span.card-title", "A"
  #       end
  #     end
  #   end
  #
  #   context "with show: icon_toggle" do
  #     it "has icon toggle and no title toggle" do
  #       expect(view_with_show(:open, :icon_toggle)).to have_tag(header_tag) do
  #         with_tag "div.d0-card-header-title" do
  #           with_tag "a.toggle-closed.slotter", with: { href: "/A?view=closed" } do
  #             with_tag :i, "expand_less"
  #           end
  #
  #           without_tag "a.toggle-closed", with:  { href: "/A" }
  #           with_tag "span.card-title", "A"
  #         end
  #       end
  #     end
  #   end
  # end
end
