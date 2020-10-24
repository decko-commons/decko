RSpec.describe Card::Set::All::NavbarLinks do
  describe "view: navbar_links" do
    it "renders pointer as dropdown" do
      content = "[[Stacks|stacky]]\n[[:recent|Recent]]"
      expect_view(:navbar_links, card: { name: "B", type: :pointer, content: content })
        .to have_tag :ul do
        with_tag "li.nav-item.dropdown" do
          with_tag "a.nav-link.dropdown-toggle", "stacky"
          with_tag "div.dropdown-menu" do
            with_tag "a.dropdown-item", "vertical"
            with_tag "a.dropdown-item", "horizontal"
          end
        end
        with_tag "li.nav-item" do
          with_tag "a.nav-link", "Recent"
        end
      end
    end

    it "handles nest" do
      content = "{{Stacks|title: stacky}}\n[[A|link to A]]"
      expect_view(:navbar_links, card: { name: "B", type: :pointer, content: content })
        .to have_tag :ul do
        with_tag "li.nav-item.dropdown" do
          with_tag "a.nav-link.dropdown-toggle", "stacky"
          with_tag "div.dropdown-menu" do
            with_tag "a.dropdown-item", "vertical"
            with_tag "a.dropdown-item", "horizontal"
          end
        end
        with_tag "li.nav-item" do
          with_tag "a.nav-link", "link to A"
        end
      end
    end

    example "divider and explicit link" do
      content = "[[Stacks|stacky]]\n[[*dropdown divider]]\n[[http://google.com|Google]]"
      expect_view(:navbar_links, card: { name: "B", type: :pointer, content: content })
        .to have_tag :ul do
        with_tag "li.nav-item.dropdown" do
          with_tag "a.nav-link.dropdown-toggle", "stacky"
          with_tag "div.dropdown-menu" do
            with_tag "a.dropdown-item", "vertical"
            with_tag "a.dropdown-item", "horizontal"
          end
        end
        with_tag "div.dropdown-divider"
        with_tag "li.nav-item" do
          with_tag "a.nav-link", "Google"
        end
      end
    end
  end
end
