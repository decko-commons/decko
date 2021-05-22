format :html do
  # deprecated; here to support old "*main menu" html cards in existing decks
  view :navbar_links, perms: :none do
    wrap_with :ul, class: "navbar-nav" do
      item_links.map do |link|
        wrap_with(:li, class: "nav-item") { link }
      end.join "\n"
    end
  end

  def item_links _args={}
    raw(render_core).split(/[,\n]/)
  end
end
