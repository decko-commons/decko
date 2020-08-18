format :html do
  # note: depends on js with selector ".edit_name-view .card-form"
  view :edit_name, perms: :update do
    frame { name_form }
  end

  # note: depends on js with selector ".name_form-view .card-form"
  view :name_form, perms: :update, wrap: :slot, cache: :never do
    name_form :edit_name_row
  end

  def name_form success_view=nil
    card_form({ action: :update, id: card.id },
              # "main-success" => "REDIRECT",
              "data-update-origin": "true",
              success: edit_name_success(success_view)) do
      [hidden_edit_name_fields,
       _render_name_formgroup,
       rename_confirmation_alert,
       edit_name_buttons]
    end
  end

  def edit_name_success view=nil
    success = { id: "_self" }
    success[:view] = view if view
    success
  end

  def hidden_edit_name_fields
    hidden_tags old_name: card.name, card: { update_referers: false }
  end

  def edit_name_buttons
    button_formgroup do
      [rename_and_update_button, rename_button, standard_cancel_button]
    end
  end

  # LOCALIZE
  def rename_and_update_button
    submit_button text: "Rename and Update", disable_with: "Renaming",
                  class: "renamer-updater"
  end

  def rename_button
    button_tag "Rename", data: { disable_with: "Renaming" }, class: "renamer"
  end

  # LOCALIZE
  def rename_confirmation_alert
    msg = "<h5>Are you sure you want to rename <em>#{safe_name}</em>?</h5>"
    msg << %(<h6>This may change names referred to by other cards.</h6>)
    msg << %(<p>You may choose to <em>update or ignore</em> the referers.</p>)
    msg << hidden_field_tag(:referers, 1)
    alert("warning", false, false, class: "hidden-alert") { msg }
  end
end
