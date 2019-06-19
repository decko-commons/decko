format :html do
  view :menu, denial: :blank, unknown: true do
    return "" if card.unknown?
    wrap_with :div, class: "card-menu #{menu_link_classes}" do
      [bridge_link(false), menu_link]
    end
  end

  def menu_link
    case voo.edit
    when :inline
      edit_inline_link
    when :full
      edit_in_bridge_link
    else # :standard
      edit_link
    end
  end

  view :edit_link, unknown: true, denial: :blank do
    edit_link
  end

  view :full_page_link do
    full_page_link
  end

  def full_page_link
    link_to_card full_page_card, full_page_icon, class: classy("full-page-link")
  end

  def full_page_card
    card
  end

  def edit_in_bridge_link opts={}
    edit_link :bridge, opts
  end

  def edit_link view=:edit, opts={}
    link_to_view view, menu_icon, edit_link_opts(opts.reverse_merge(modal: :lg))
  end

  # @param modal [Symbol] modal size
  def edit_link_opts modal: nil
    opts = { class: classy("edit-link") }
    if modal
      opts.merge! "data-slotter-mode": "modal", "data-modal-class": "modal-#{modal}"
    end
    opts
  end

  def menu_link_classes
    "nodblclick" + (show_view?(:hover_link) ? " _show-on-hover" : "")
  end

  def menu_icon
    material_icon "edit"
  end

  def full_page_icon
    icon_tag :open_in_new
  end
end
