format :html do
  view :edit_content_form, wrap: :slot do
    with_nest_mode :edit do
      edit_form
    end
  end

  def edit_form
    card_form(:update, edit_form_opts) do
      [
        edit_view_hidden,
        _render_content_formgroup,
        _render_edit_buttons
      ]
    end
  end

  view :edit_content, perms: :update, tags: :unknown_ok, cache: :never,
       wrap: { modal: { footer: "",
                        title: :render_title } } do
    with_nest_mode :edit do
      voo.show :help
      voo.hide :save_button
      wrap true do
        _render_edit_content_form
      end
    end
  end

  def edit_form_opts
    # for override
    { "data-slot-selector": "._modal-origin", "data-slot-error-selector": ".card-slot" }
  end
end
