format :html do
  OVERLAY_CLOSE_OPTS = { class: "_close-overlay btn-sm",
                         "data-dismiss": "overlay",
                         type: "button" }.freeze

  wrapper :overlay do |opts|
    class_up "card-slot", "_overlay d0-card-overlay bg-body"
    @content_body = true
    voo.hide! :menu
    overlay_frame true, overlay_header(opts[:title]), opts[:slot] do
      interior
    end
  end

  view :overlay_header, unknown: true do
    overlay_header
  end

  view :overlay_title do
    _render_title
  end

  view :overlay_menu do
    wrap_with :div, class: "btn-group btn-group-sm align-self-start ml-auto" do
      [slotify_overlay_link, close_overlay_link]
    end
  end

  def slotify_overlay_link
    overlay_menu_link "external-link-square", card: card
  end

  def close_overlay_link
    overlay_menu_link :close, path: "#", "data-dismiss": "overlay"
  end

  def overlay_close_button link_text="Close", opts={}
    classes = opts.delete(:class)
    button_opts = opts.merge(OVERLAY_CLOSE_OPTS)
    add_class button_opts, classes if classes
    button_tag link_text, button_opts
  end

  def overlay_save_and_close_button
    submit_button text: "Save and Close", class: "_close-overlay-on-success",
                  "data-cy": "submit-overlay"
  end

  def overlay_menu_link icon, args={}
    add_class args, "border-light text-dark p-1 ml-1"
    button_link fa_icon(icon, class: "fa-lg"), args.merge(btn_type: "outline-secondary")
  end

  def overlay_header title=nil
    title ||= _render_overlay_title
    class_up "d0-card-header", "bg-body"
    class_up "d0-card-header-title", "d-flex"
    header_wrap [title, _render_overlay_menu]
  end

  def overlay_frame slot=true, header=render_overlay_header, slot_opts=nil
    slot_opts ||= {}
    overlay_framer slot, header, slot_opts do
      wrap_body { yield }
    end
  end

  def haml_overlay_frame slot=true, header=render_overlay_header
    overlay_framer slot, header, {} do
      haml_wrap_body { yield }
    end
  end

  private

  def overlay_framer slot, header, slot_opts
    class_up "card-slot", "_overlay"
    with_frame slot, header, slot_opts do
      yield
    end
  end
end
