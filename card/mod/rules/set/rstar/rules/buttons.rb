format :html do
  def edit_rule_buttons
    wrap_with(:div, class: "button-area") do
      [
        standard_save_button(class: "_rule-submit-button"),
        standard_save_and_close_button(class: "_rule-submit-button", close: :overlay),
        edit_rule_cancel_button,
        edit_rule_delete_button
      ]
    end
  end

  def edit_rule_cancel_button
    overlay_close_button "Cancel", situation: "secondary", class: "btn-sm"
  end

  def edit_rule_delete_button args={}
    return if card.new_card?

    delete_opts = {
      confirm: delete_confirm(args[:fallback_set]),
      success: @edit_rule_success,
      class: "_close-overlay-on-success"
    }
    delete_opts["data-slot-selector"] = slot_selector if args[:slot_selector]
    wrap_with :span, class: "rule-delete-section" do
      delete_button delete_opts
    end
  end

  def delete_confirm fallback_set
    setting = card.rule_setting_name

    if fallback_set && (fallback_set_card = Card.fetch(fallback_set))
      "Deleting will revert to #{setting} rule for #{fallback_set_card.label}"
    else
      "Are you sure you want to delete the #{setting} rule for #{rule_set_description}?"
    end
  end


  def edit_rule_submit_button
    submit_button class: "_rule-submit-button"
  end

  # def edit_rule_cancel_button
  #   cancel_view = card.new_card? ? :closed_rule : :open_rule
  #   cancel_button class: "rule-cancel-button",
  #                 href: path(view: cancel_view, success: false)
  # end
end
