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

  def rename_and_update_button
    submit_button text: "Rename and Update", disable_with: "Renaming",
                  class: "renamer-updater"
  end

  def rename_button
    button_tag "Rename", data: { disable_with: "Renaming" }, class: "renamer"
  end

  def rename_confirmation_alert
    msg = "<h5>Are you sure you want to rename <em>#{safe_name}</em>?</h5>"
    msg << rename_effects_and_options
    alert("warning", false, false, class: "hidden-alert") { msg }
  end

  def rename_effects_and_options
    descendant_effect = rename_descendant_effect
    referer_effect, referer_option = rename_referer_effect_and_option
    effects = [descendant_effect, referer_effect].compact
    return "" if effects.empty?

    format_rename_effects_and_options effects, referer_option
  end

  def format_rename_effects_and_options effects, referer_option
    effects = effects.map { |effect| "<li>#{effect}</li>" }.join
    info = %(<h6>This change will...</h6>)
    info += %(<ul>#{effects}</ul>)
    info += %(<p>#{referer_option}</p>) if referer_option
    info
  end

  def rename_descendant_effect
    descendants = card.descendants
    return unless descendants.any? # FIXME: count, don't instantiate

    "automatically alter #{descendants.size} related name(s)."
  end

  def rename_referer_effect_and_option
    referers = card.family_referers
    return unless referers.any? # FIXME: count, don't instantiate

    count = referers.size
    refs = count == 1 ? "reference" : "references"
    effect = "affect at least #{count} #{refs} to \"#{card.name}\""
    effect += hidden_field_tag(:referers, count)
    option = "You may choose to <em>update or ignore</em> the referers."
    [effect, option]
  end
end
