format :html do
  view :edit_name, perms: :update do
    frame { name_form }
  end

  view :name_form, perms: :update, wrap: :slot, cache: :never do
    name_form :edit_name_row
  end

  private

  def name_form success_view=nil
    card_form({ action: :update, id: card.id },
              { "data-main-success": JSON(redirect: true, view: ""),
                "data-slotter-mode": "update-origin",
                class: "_rename-form",
                success: edit_name_success(success_view) }) do
      [_render_name_formgroup,
       edit_name_skip_referers,
       edit_name_buttons]
    end
  end

  def edit_name_skip_referers
    haml :edit_name_skip_referers
  end

  def edit_name_success view=nil
    success = { name: "_self", redirect: "" }
    success[:view] = view if view
    success
  end

  def edit_name_buttons
    class_up "button-form-group", "rename-button-form-group"
    button_formgroup do
      [rename_button, standard_cancel_button]
    end
  end

  def rename_button
    button_tag t(:core_rename),
               class: "renamer", data: { disable_with: t(:core_renaming),
                                         confirm: t(:core_rename_confirm) }
  end
end
