format :html do
  view :menu, denial: :blank, tags: :unknown_ok do
    return "" if card.unknown?
    wrap_with :div, class: "card-menu #{menu_link_classes}" do
      menu
    end
  end

  def menu
    case voo.edit
    when :content_inline
      edit_in_place_link
    when :content_modal
      edit_in_modal_link
    else
      standard_edit_link
    end
  end

  view :edit_link, tags: :unknown_ok, denial: :blank do
    edit_link
  end

  view :full_page_link do
    full_page_link
  end

  def full_page_link
    link_to_card card, full_page_icon, class: classy("full-page-link")
  end

  def edit_link view=:edit, opts={}
    link_to_view view, menu_icon, edit_link_opts(opts)
  end

  # @param modal [Symbol] modal size
  def edit_link_opts modal: nil
    opts = { remote: true, class: "slotter text-muted" }
    opts.merge "data-slotter-mode": "modal", "data-modal-class": "modal-#{modal}" if modal
    opts
  end

  def wrap_menu
    wrap_with :div, class: classy(%w[menu-slot nodblclick]) do
      yield
    end
   end

  def standard_edit_link
    edit_link :edit, modal: :full
  end

  def edit_in_modal_link
    edit_link :edit, modal: :large
  end

  def edit_in_place_link
    edit_link :edit_in_place
  end

  def menu_link_classes
    if show_view? :hover_link
      "_show-on-hover"
    else
      ""
    end
  end

  def menu_icon
    fa_icon "edit"
  end

  def full_page_icon
    icon_tag :open_in_new
  end

  def show_menu_item_edit?
    return unless card.real?

    card.ok?(:update) || structure_editable?
  end
end
