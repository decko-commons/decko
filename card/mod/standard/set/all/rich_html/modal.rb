format :html do
  MODAL_SIZE = { small: "sm", medium: nil, large: "lg", full: "full" }.freeze
  MODAL_CLOSE_OPTS = { class: "_close-modal", "data-dismiss": "modal",
                       "data-cy": "close-modal" }.freeze

  wrapper :modal do |opts={}|
    haml :modal_dialog, body: interior,
                        classes: modal_dialog_classes(opts),
                        title: normalize_modal_option(:title, opts),
                        menu: normalize_modal_option(:menu, opts),
                        footer: normalize_modal_option(:footer, opts)
  end

  def normalize_modal_option key, opts
    val = opts[key]
    return render("modal_#{key}") unless val
    cast_model_option val
  end

  def cast_model_option val
    case val
    when Symbol
      respond_to?(val) ? send(val) : val
    when Proc
      val.call(self)
    else
      val
    end
  end

  view :modal, wrap: :modal do
    ""
  end

  def show_in_modal_link link_text, body
    link_to_view :modal, link_text,
                 "data-modal-body": body, "data-slotter-mode": "modal", class: "slotter"
  end

  def modal_close_button link_text="Close", opts={}
    classes = opts.delete(:class)
    button_opts = opts.merge(MODAL_CLOSE_OPTS)
    add_class button_opts, classes if classes
    button_tag link_text, button_opts
  end

  def modal_submit_button opts={}
    add_class opts, "submit-button _close-modal"
    submit_button opts
  end

  view :modal_menu, tags: :unknown_ok, wrap: :modal_menu do
    [close_modal_window, pop_out_modal_window]
  end

  wrapper :modal_menu, :div, class: "modal-menu ml-auto"

  view :modal_title, tags: :unknown_ok do
    ""
  end

  view :modal_footer, tags: :unknown_ok do
    button_tag "Close",
               class: "btn-xs _close-modal float-right",
               "data-dismiss" => "modal"
  end

  view :modal_link do
    modal_link _render_title, size: voo.size
  end



  # @param size [:small, :medium, :large, :full] size of the modal dialog
  def modal_link text=nil, opts={}
    opts = modal_link_opts(opts)
    opts[:path][:layout] ||= :modal
    link_to text, opts
  end

  def modal_link_opts opts
    add_class opts, "slotter"
    opts.reverse_merge! path: {},
                        "data-slotter-mode": "modal",
                        "data-modal-class": modal_dialog_classes(opts),
                        remote: true
    opts
  end


  def modal_dialog_classes opts
    classes = [classy("modal-dialog")]
    return classes unless opts.present?

    add_modal_size_class classes, opts.delete(:size)
    classes << "modal-dialog-centered" if opts.delete(:vertically_centered)
    classes.join " "
  end

  def add_modal_size_class classes, size
    size = cast_model_option size unless size.in?(MODAL_SIZE.keys)

    classes << "modal-#{MODAL_SIZE[size]}" if size && size != :medium
  end


  def close_modal_window
    link_to icon_tag(:close), path: "",
                              class: "_close-modal close",
                              "data-dismiss": "modal"
  end

  def pop_out_modal_window
    # we probably want to pass on a lot more params than just view,
    # but not all of them
    # (eg we don't want layout, id, controller...)
    popout_params = params[:view] ? { view: params[:view] } : {}
    link_to icon_tag(:new_window), path: popout_params,
                                   class: "pop-out-modal close"
  end
end
