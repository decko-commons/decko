format :html do
  view :navbar_links, perms: :none do
    wrap_with :ul, class: "navbar-nav" do
      navbar_items
    end
  end

  # Iterates over all nests and links and renders them as bootstrap navbar items.
  # Items that are pointer cards become dropdowns
  def navbar_items view: :nav_item, link_class: "nav-link"
    process_content nil, chunk_list: :references do |chunk|
      case chunk
      when Card::Content::Chunk::Link
        link = chunk.render_link view: view, explicit_link_opts: { class: link_class }
        chunk.explicit_link? && view == :nav_item ? wrap_with_nav_item(link) : link
      when Card::Content::Chunk::Nest
        content_nest chunk.options.merge view: view
      else
        chunk.process_chunk
      end
    end
  end

  # overridden in Abstact::Pointer to render dropdown
  view :nav_item do
    wrap_with_nav_item link_view(class: "nav-link")
  end

  def wrap_with_nav_item content
    wrap_with(:li, content, class: "nav-item")
  end

  view :nav_link_in_dropdown do
    link_to_card card, render_title, class: "dropdown-item"
  end

  def nav_dropdown
    wrap_with(:li, class: "nav-item dropdown") do
      [
        dropdown_toggle_link,
        dropdown_menu
      ]
    end
  end

  def dropdown_toggle_link
    link_to(render_title, href: "#", class: "nav-link dropdown-toggle",
                          "data-toggle": "dropdown")
  end

  def dropdown_menu
    wrap_with :div, dropdown_menu_items, class: "dropdown-menu"
  end

  def dropdown_menu_items
    navbar_items view: :nav_link_in_dropdown, link_class: "dropdown-item"
  end
end
