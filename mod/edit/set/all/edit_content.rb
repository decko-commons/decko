format :html do
  view :edit_form, wrap: :slot do
    voo.show :edit_type_row
    with_nest_mode :edit do
      edit_form
    end
  end

  def edit_form
    voo.hide :edit_type_row
    form_opts = edit_form_opts.reverse_merge success: edit_success
    card_form(:update, form_opts) do
      [
        edit_view_hidden,
        _render_edit_type_row(home_view: :edit_type_row),
        # home_view is necessary for cancel to work correctly.
        # it seems a little strange to have to think about home_view here,
        # but the issue is that something currently has to happen prior to the
        # render to get voo.slot_options to have the write home view in
        # the slot wrap. Id think this would probably best be handled as an
        # option to #wrap that triggers a new heir voo
        _render_content_formgroups,
        _render_edit_buttons
      ]
    end
  end

  view :edit, perms: :update, unknown: true, cache: :never,
              wrap: { modal: { footer: "",
                               size: :edit_modal_size,
                               title: :render_title,
                               menu: :edit_modal_menu } } do
    add_name_context
    with_nest_mode :edit do
      voo.show :help
      voo.hide :save_button
      wrap true do
        [
          frame_help,
          _render_edit_form
        ]
      end
    end
  end

  def edit_modal_size
    :large
  end

  def edit_modal_menu
    wrap_with_modal_menu do
      [close_modal_window, render_bridge_link]
    end
  end

  def edit_form_opts
    # for override
    { "data-slot-selector": "modal-origin", "data-slot-error-selector": ".card-slot" }
  end
end
