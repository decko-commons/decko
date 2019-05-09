format :html do
  view :edit_content_form, wrap: :slot do
    with_nest_mode :edit do
      edit_form
    end
  end

  def edit_form
    form_opts = edit_form_opts.reverse_merge success: edit_success
    card_form(:update, form_opts) do
      [
        edit_view_hidden,
        _render_content_formgroup,
        _render_edit_buttons
      ]
    end
  end

  view :edit, perms: :update, unknown: true, cache: :never,
              wrap: { modal: { footer: "",
                               size: :edit_modal_size,
                               title: :render_title,
                               menu: :edit_modal_menu } } do
    with_nest_mode :edit do
      voo.show :help
      voo.hide :save_button
      wrap true do
        [
          frame_help,
          _render_edit_content_form
        ]
      end
    end
  end

  view :bridge_link, unknown: true do
    bridge_link
  end

  def edit_modal_size
    :large
  end

  def edit_modal_menu
    wrap_with_modal_menu do
      [close_modal_window, render_bridge_link]
    end
  end

  def bridge_link in_modal=true
    opts = { class: "text-muted" }
    if in_modal
      add_class opts, "close"
      opts["data-slotter-mode"] = "modal-replace"
    end
    link_to_view :bridge, material_icon(:more_horiz), opts
  end

  def edit_form_opts
    # for override
    { "data-slot-selector": "modal-origin", "data-slot-error-selector": ".card-slot" }
  end
end
