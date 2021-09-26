format :html do
  OVERLAY_CLOSE_OPTS = { class: "_close-overlay btn-sm",
                         "data-dismiss": "overlay",
                         type: "button" }.freeze

  wrapper :overlay do |opts|
    class_up "card-slot", "_overlay d0-card-overlay bg-body", :single_use
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
      [render_overlay_help_link, slotify_overlay_link, close_overlay_link]
    end
  end

  view :overlay_help_link, cache: :never, unknown: true do
    opts = help_popover_opts
    add_open_guide_opts opts
    overlay_menu_link "question-circle", opts
  end

  def add_open_guide_opts opts
    return unless card.guide_card

    slot_selector = ".bridge-sidebar > ._overlay-container-placeholder > .card-slot"
    opts.merge! remote: true,
                href: path(mark: card, view: :overlay_guide),
                "data-slot-selector": slot_selector,
                "data-slotter-mode": "overlay"
    add_class opts, "slotter"
  end

  def slotify_overlay_link
    overlay_menu_link "external-link-square-alt", card: card
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

  def overlay_delete_button
    delete_button OVERLAY_CLOSE_OPTS.merge(success: {})
  end

  def overlay_save_and_close_button
    submit_button text: "Save and Close", class: "_close-on-success",
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

  def overlay_frame slot=true, header=render_overlay_header, slot_opts=nil, &block
    slot_opts ||= {}
    overlay_framer slot, header, slot_opts do
      wrap_body(&block)
    end
  end

  def haml_overlay_frame slot=true, header=render_overlay_header, &block
    overlay_framer slot, header, {} do
      haml_wrap_body(&block)
    end
  end

  private

  def overlay_framer slot, header, slot_opts, &block
    class_up "card-slot", "_overlay", :single_use
    with_frame slot, header, slot_opts, &block
  end
end
