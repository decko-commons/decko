format :html do
  view :menu, denial: :blank, unknown: true do
    return "" if card.unknown?

    wrap_with :div, class: "card-menu #{menu_link_classes}" do
      [help_link, menu_link, bridge_link(false)]
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
    edit_link edit_link_view, link_text: voo.title
  end

  def edit_link_view
    :edit
  end

  view :full_page_link do
    full_page_link
  end

  view :bridge_link, unknown: true do
    bridge_link
  end

  def bridge_link in_modal=true
    opts = { class: "bridge-link" }
    if in_modal
      # add_class opts, "close"
      opts["data-slotter-mode"] = "modal-replace"
    end
    link_to_view :bridge, material_icon(:more_horiz), opts
  end

  def help_link
    help_link_popover # ? help_link_slotter : help_link_popover
  end

  def help_slot?
    false
  end

  def help_icon
    material_icon("help")
  end

  def help_text
    ""
  end

  def help_title
    "#{name_parts_links} #{full_page_link unless card.simple?} (#{render_type})"
  end

  def name_parts_links
    card.name.parts.map do |part|
      link_to_card part
    end.join Card::Name.joint
  end

  def help_link_popover
    popover_link render_help_text, help_title, help_icon, "data-placement": :left,
                 class: "help-link"
  end

  def help_link_slotter
    link_to_view :help, help_icon,
                 path: { slot: { show: :help_text } }, class: "help-link",
                 "data-slot-selector" => ".card-slot.help_text_view"
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
    link_to_view view, opts.delete(:link_text) || menu_icon,
                 edit_link_opts(opts.reverse_merge(modal: :lg))
  end

  # @param modal [Symbol] modal size
  def edit_link_opts modal: nil
    opts = { class: classy("edit-link") }
    if modal
      opts[:"data-slotter-mode"] = "modal"
      opts[:"data-modal-class"] = "modal-#{modal}"
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
