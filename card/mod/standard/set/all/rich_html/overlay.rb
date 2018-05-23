format :html do
  view :overlay do
    overlay [_render_open_content, render_comment_box]
  end

  def overlay content=nil
    class_up "card-slot", "_overlay d0-card-overlay bg-white", true
    @content_body = true
    frame do
      block_given? ? yield : content
    end
  end

  view :overlay_menu do
    wrap_with :div, class: "btn-group btn-group-sm" do
      [slotify_overlay_link, close_overlay_link]
    end
  end

  def slotify_overlay_link
    overlay_menu_link "external-link-square", card: card
  end

  def close_overlay_link
    overlay_menu_link :close, path: "#", "data-dismiss": "overlay"
  end

  def overlay_menu_link icon, args={}
    add_class args, "border-light text-dark p-1"
    button_link fa_icon(icon, class: "fa-lg"), args.merge(btn_type: "outline-secondary")
  end

  view :overlay_header do
    class_up "d0-card-header", "bg-white text-dark", true
    class_up "d0-card-header-title", "d-flex justify-content-between", true
    header_wrap [_render_title, _render_overlay_menu]
  end
end
