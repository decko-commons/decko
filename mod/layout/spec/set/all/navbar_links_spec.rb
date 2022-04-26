RSpec.describe Card::Set::All::NavbarLinks do
  describe "view: navbar_links" do
    def expect_navbar_link content
      expect_view(
        :navbar_links, card: { name: "B", type: :pointer, content: content }
      ).to have_tag :ul do
        with_tag "li.nav-item.dropdown" do
          with_tag "a.nav-link.dropdown-toggle", "stacky"
          with_tag "div.dropdown-menu" do
            with_tag "a.dropdown-item", "vertical"
            with_tag "a.dropdown-item", "horizontal"
          end
        end
        # with_tag "div.dropdown-divider" if divider
        with_tag "li.nav-item" do
          with_tag "a.nav-link", yield
        end
      end
    end

    it "renders pointer as dropdown" do
      expect_navbar_link("[[Stacks|stacky]]\n[[:recent|Recent]]") { "Recent" }
    end

    it "handles nest" do
      expect_navbar_link("{{Stacks|title: stacky}}\n[[A|link to A]]") { "link to A" }
    end

    example "divider and explicit link" do
      content = "[[Stacks|stacky]]\n[[http://google.com|Google]]"
      expect_navbar_link(content) { "Google" }
    end
  end
end
