format :html do
  view :modal_link, tags: :unknown_ok do |args|
    opts = args[:link_opts]
    opts[:path][:layout] ||= :modal
    text = args[:link_text] || _render_title(args)
    link_to text, opts
  end

  def default_modal_link_args args
    args[:link_opts] ||= {}
    args[:link_opts].reverse_merge! path: {},
                                    "data-target": "#modal-main-slot",
                                    "data-toggle": "modal"
  end

  view :modal_slot, tags: :unknown_ok do |args|
    id = "modal-#{args[:modal_id] || 'main-slot'}"
    dialog_args = { class: "modal-dialog" }
    add_class dialog_args, args[:dialog_class]
    wrap_with(:div, class: "modal fade _modal-slot", role: "dialog", id: id) do
      wrap_with(:div, dialog_args) do
        wrap_with :div, class: "modal-content" do
          ""
        end
      end
    end
  end

  view :modal_menu, tags: :unknown_ok do
    wrap_with :div, class: "modal-menu w-100" do
      [close_modal_window, popop_out_modal_window]
    end
  end

  def close_modal_window
    link_to icon_tag(:close), path: "",
                              class: "close-modal float-right close",
                              "data-dismiss": "modal"
  end

  def popop_out_modal_window
    # we probably want to pass on a lot more params than just view,
    # but not all of them
    # (eg we don't want layout, id, controller...)
    popout_params = params[:view] ? { view: params[:view] } : {}
    link_to icon_tag :new_window, path: popout_params,
                                  class: "pop-out-modal float-right close "
  end

  view :modal_footer, tags: :unknown_ok do
    button_tag "Close",
               class: "btn-xs close-modal float-right",
               "data-dismiss" => "modal"
  end
end
