format :html do
  view :edit_name, perms: :update do
    frame { name_form }
  end

  view :name_form, perms: :update, wrap: :slot, cache: :never do
    name_form :edit_name_row
  end

  def name_form success_view=nil
    card_form({ action: :update, id: card.id },
              "data-main-success": JSON(redirect: true, view: ""),
              "data-update-origin": "true",
              class: "_rename-form",
              success: edit_name_success(success_view)) do
      [edit_name_hidden_fields,
       _render_name_formgroup,
       edit_name_confirmation,
       edit_name_buttons]
    end
  end

  def edit_name_success view=nil
    success = { name: "_self", redirect: "" }
    success[:view] = view if view
    success
  end

  def edit_name_hidden_fields
    hidden_tags old_name: card.name, card: { update_referers: false }
  end

  def edit_name_buttons
    class_up "button-form-group", "rename-button-form-group"
    button_formgroup do
      [rename_and_update_button, rename_button, standard_cancel_button]
    end
  end

  def edit_name_confirmation
    alert "warning", false, false, class: "hidden-alert" do
      haml :edit_name_confirmation, referer_count: card.references_in.count
    end
  end

  def rename_and_update_button
    submit_button text: t(:core_rename_and_update),
                  disable_with: t(:core_renaming),
                  class: "_renamer-updater"
  end

  def rename_button
    button_tag t(:core_rename),
               class: "renamer", data: { disable_with: t(:core_renaming) }
  end
end
