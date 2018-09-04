format :html do
  MODAL_SIZE = { small: "sm", medium: nil, large: "lg", full: "full" }.freeze

  wrapper :modal do |opts={}|
    haml :modal_dialog, body: interiour,
                        classes: modal_dialog_classes(opts),
                        title: opts[:title]  || "",
                        menu: opts[:menu] || render_modal_menu,
                        footer: opts[:footer] || render_modal_footer
  end

  view :modal_menu, tags: :unknown_ok do
    wrap_with :div, class: "modal-menu ml-auto" do
      [close_modal_window, pop_out_modal_window]
    end
  end

  view :modal_footer, tags: :unknown_ok do
    button_tag "Close",
               class: "btn-xs close-modal float-right",
               "data-dismiss" => "modal"
  end

  view :modal_link do
    modal_link _render_title, size: voo.size
  end

  # @param size [:small, :medium, :large, :full] size of the modal dialog
  def modal_link text=nil, opts={}
    link_to text, modal_link_opts(opts)
  end

  def modal_dialog_classes opts
    classes = [classy("modal-dialog")]
    return classes unless opts.present?
    size = opts.delete :size
    classes << "modal-#{MODAL_SIZE[size]}" if size && size != :medium
    classes << "modal-dialog-centered" if opts.delete(:vertically_centered)
    classes.join " "
  end

  def modal_link_opts opts
    add_class opts, "_modal-link"
    opts.reverse_merge! path: {},
                        "data-toggle": "modal",
                        "data-target": "#modal-main-slot",
                        "data-modal-class": modal_dialog_classes(opts)

    opts[:path][:layout] ||= :modal
    opts[:path] = "javascript:void()"
    opts
  end

  def close_modal_window
    link_to icon_tag(:close), path: "",
                              class: "close-modal float-right close",
                              "data-dismiss": "modal"
  end

  def pop_out_modal_window
    # we probably want to pass on a lot more params than just view,
    # but not all of them
    # (eg we don't want layout, id, controller...)
    popout_params = params[:view] ? { view: params[:view] } : {}
    link_to icon_tag(:new_window), path: popout_params,
                                   class: "pop-out-modal float-right close "
  end
end
