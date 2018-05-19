format :html do
  def modal_link text, opts={}
    text ||= render_title
    opts.reverse_merge! path: {},
                        "data-target": "#modal-main-slot",
                        "data-toggle": "modal"
    opts[:path][:layout] ||= :modal
    link_to text, opts
  end

  def modal_slot modal_id=nil, dialog_class=nil
    wrap_with :div, class: "modal fade _modal-slot",
                    role: "dialog", id: "modal-#{modal_id || 'main-slot'}" do
      wrap_with :div, class: css_classes("modal-dialog", dialog_class) do
        wrap_with(:div, class: "modal-content") { "" }
      end
    end.html_safe
  end

  view :modal_menu, tags: :unknown_ok do
    wrap_with :div, class: "modal-menu w-100" do
      [close_modal_window, pop_out_modal_window]
    end
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

  view :modal_footer, tags: :unknown_ok do
    button_tag "Close",
               class: "btn-xs close-modal float-right",
               "data-dismiss" => "modal"
  end
end
