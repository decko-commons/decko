format :html do
  wrapper :overlay do |opts|
    class_up "card-slot", "_overlay d0-card-overlay bg-white", true
    @content_body = true
    overlay_frame true, overlay_header(opts[:title]) do
      interiour
    end
  end

  view :overlay_header, tags: :unknown_ok do
    overlay_header
  end

  view :overlay_title do
    _render_title
  end

  view :overlay_menu do
    wrap_with :div, class: "btn-group btn-group-sm align-self-start" do
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
    add_class args, "border-light text-dark p-1 ml-1"
    button_link fa_icon(icon, class: "fa-lg"), args.merge(btn_type: "outline-secondary")
  end

  def overlay_header title=nil
    title ||= _render_overlay_title
    class_up "d0-card-header", "bg-white text-dark", true
    class_up "d0-card-header-title", "d-flex justify-content-between", true
    header_wrap [title, _render_overlay_menu]
  end

  def overlay_frame slot=true, header=render_overlay_header
    overlay_framer slot, header do
      wrap_body { yield }
    end
  end

  def haml_overlay_frame slot=true, header=render_overlay_header
    overlay_framer slot, header do
      haml_wrap_body { yield }
    end
  end

  private

  def overlay_framer slot, header
    class_up "card-slot", "_overlay"
     with_frame slot, header do
       yield
     end
  end
end
