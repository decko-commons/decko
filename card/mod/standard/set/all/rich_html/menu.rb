format :html do
  view :menu, denial: :blank, tags: :unknown_ok do
    return "" if card.unknown?

    menu
  end

  def menu
    wrap_with :div, class: "card-menu #{menu_link_classes} float-right" do
      link_to_view "edit", menu_icon,
                   remote: true, "data-slotter-mode": "modal",
                   class: "slotter", "data-modal-class": "modal-full"
    end
  end

  def menu_link_classes
    if show_view? :hover_link
      show_view?(:horizontal_menu, :hide) ? "d-sm-none" : "_show-on-hover"
    else
      ""
    end
  end

  # this should probably be added in javascript.
  # the menu link is not a "slotter", because it doesn't replace the whole
  # slot (it just adds a menu). But it should use the js code that adds slot
  # information to urls
  def menu_link_path_opts
    opts = { slot: { home_view: voo.home_view } }
    opts[:is_main] = true if main?
    opts
  end

  def menu_icon
    fa_icon "edit"
  end

  def menu_item_page opts
    menu_item "page", "open_in_new", opts.merge(card: card)
  end

  def menu_item_rules opts
    menu_item "rules", "build", opts.merge(view: :edit_rules)
  end

  def menu_item_account opts
    menu_item "account", "person", opts.merge(
      view: :related,
      path: { slot: { items: { nest_name: "+#{:account.cardname.key}", view: :edit } } }
    )
  end

  def show_menu_item_page?
    card.name.present? && !main?
  end

  def show_menu_item_edit?
    return unless card.real?

    card.ok?(:update) || structure_editable?
  end
end
