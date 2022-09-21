format :html do
  MODAL_SIZE = { small: "sm", medium: nil, large: "lg",  full: "full", xl: "xl" }.freeze
  MODAL_CLOSE_OPTS = { "data-bs-dismiss": "modal",
                       "data-cy": "close-modal" }.freeze

  wrapper :modal do |opts={}|
    haml :modal_dialog, body: interior,
                        classes: modal_dialog_classes(opts),
                        title: normalize_modal_option(:title, opts),
                        menu: normalize_modal_option(:menu, opts),
                        footer: normalize_modal_option(:footer, opts)
  end

  view :modal, wrap: :modal do
    ""
  end

  def show_in_modal_link link_text, body
    link_to_view :modal, link_text, "data-modal-body": body, "data-slotter-mode": "modal"
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

  view :modal_menu, unknown: true, wrap: :modal_menu do
    [close_modal_window, pop_out_modal_window]
  end

  wrapper :modal_menu, :div, class: "modal-menu _modal-menu ms-auto"

  view :modal_title, unknown: true do
    ""
  end

  view :modal_footer, unknown: true do
    button_tag "Close",
               class: "btn-xs _close-modal float-end",
               "data-bs-dismiss" => "modal"
  end

  view :modal_link do
    modal_link _render_title, size: voo.size
  end

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

    add_modal_size_class classes, opts[:size]
    classes << "modal-dialog-centered" if opts[:vertically_centered]
    classes.join " "
  end

  def add_modal_size_class classes, size
    size = normalize_modal_size_class size
    return if size == :medium || size.blank?

    classes << "modal-#{MODAL_SIZE[size]}"
  end

  def normalize_modal_size_class size
    size.in?(MODAL_SIZE.keys) ? size : cast_modal_option(size)
  end

  def close_modal_window
    link_to icon_tag(:close), path: "",
                              class: "_close-modal btn-close",
                              "data-bs-dismiss": "modal"
  end

  def pop_out_modal_window
    link_to icon_tag(:new_window), path: {}, class: "pop-out-modal btn-close"
  end

  private

  def normalize_modal_option key, opts
    val = opts[key]
    return render("modal_#{key}") unless val

    cast_modal_option val
  end

  def cast_modal_option val
    case val
    when Symbol
      cast_modal_option_symbol val
    when Proc
      val.call(self)
    else
      val
    end
  end

  def cast_modal_option_symbol val
    respond_to?(val) ? send(val) : val
  end
end
