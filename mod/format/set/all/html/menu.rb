format :html do
  view :menu, denial: :blank, unknown: true do
    return "" unless card.known?
    # would be preferable to do this with unknown: :blank, but that fails with view
    # caching on, because voo always thinks it's the root.
    wrap_with :div, class: "card-menu #{menu_link_classes}" do
      [render_help_link,
       menu_link,
       (voo.show?(:bridge_link) ? bridge_link(in_modal: false) : nil)]
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

  def edit_view
    case voo.edit
    when :inline
      :edit_inline
    when :full
      :edit
    else # :standard
      edit_link
    end
  end

  view :edit_link, unknown: true, denial: :blank do
    edit_link edit_link_view
  end

  view :edit_button do
    view = voo.edit == :inline ? :edit_inline : :edit
    link_to_view view, "Edit", class: "btn btn-sm btn-outline-primary me-2"
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

  def bridge_link text: "", in_modal: true, confirm: false
    opts = { class: "bridge-link" }
    opts["data-slotter-mode"] = "modal-replace" if in_modal
    confirm_edit_loss opts if confirm
    link_to_view :bridge, "#{bridge_icon} #{text}", opts
  end

  # no caching because help_text view doesn't cache, and we can't have a
  # stub in the data-content attribute or it will get html escaped.
  view :help_link, cache: :never, unknown: true do
    help_link render_help_text, help_title
  end

  def help_link text=nil, title=nil
    opts = help_popover_opts text, title
    add_class opts, "_card-menu-popover"
    link_to icon_tag(:help), opts
  end

  def help_popover_opts text=nil, title=nil
    text ||= render_help_text
    opts = { "data-bs-placement": :left, class: "help-link" }
    popover_opts text, title, opts
  end

  def help_title
    "#{name_parts_links} (#{render_type}) #{full_page_link unless card.simple?}"
  end

  def name_parts_links
    card.name.parts.map do |part|
      link_to_card part
    end.join Card::Name.joint
  end

  def full_page_link text: ""
    link_to_card full_page_card, "#{full_page_icon} #{text}",
                 class: classy("full-page-link")
  end

  def modal_page_link text: ""
    modal_link "#{modal_icon} #{text}",
               path: { mark: card }, size: modal_page_size, class: "_modal-page-link"
  end

  def modal_page_size
    :xl
  end

  def full_page_card
    card
  end

  def edit_in_bridge_link opts={}
    edit_link :bridge, *opts
  end

  def edit_link view=:edit, link_text: nil, text: "", modal: nil
    link_to_view view, link_text || "#{menu_icon} #{text}",
                 edit_link_opts(modal: (modal || :lg))
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
    "nodblclick#{show_view?(:hover_link) ? ' _show-on-hover' : ''}"
  end

  def menu_icon
    icon_tag "edit"
  end

  def full_page_icon
    icon_tag :open_in_new
  end

  def modal_icon
    icon_tag :modal
  end

  def bridge_icon
    icon_tag :board
  end

  def confirm_edit_loss opts
    add_class opts, "_confirm"
    opts["data-confirm-msg"] = t(:format_confirm_edit_loss)
  end
end
