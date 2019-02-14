format :html do
  view :menu, denial: :blank, tags: :unknown_ok do
    return "" if card.unknown?

    menu
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

  def edit_link view, opts={}
    link_to_view view, menu_icon, edit_link_opts(opts)
  end

  # @param modal [Symbol] modal size
  def edit_link_opts modal: nil
    modal ? { "data-slotter-mode": "modal", "data-modal-class": "modal-#{modal}"  } : {}
  end

  def wrap_menu
    wrap_with :div, class: classy(%w[menu-slot nodblclick]) do
      yield
    end
   end

  def standard_edit_link
    wrap_with :div, class: "card-menu #{menu_link_classes} float-right" do
      edit_link :edit, modal: :full
    end
  end

  def edit_in_modal_link
    edit_link :edit, modal: :large
  end

  def edit_in_place_link
    edit_link :edit_in_place
  end

  def menu_link_classes
    if show_view? :hover_link
      show_view?(:horizontal_menu, :hide) ? "d-sm-none" : "_show-on-hover"
    else
      ""
    end
  end

  def menu_icon
    fa_icon "edit"
  end

  def show_menu_item_edit?
    return unless card.real?

    card.ok?(:update) || structure_editable?
  end
end
