format :html do
  view :input do
    "Content can't be edited."
  end

  def short_content
    fa_icon("exclamation-circle", class: "text-muted pe-2") +
      wrap_with(:span, "read-only", class: "text-muted")
  end

  def standard_submit_button
    multi_card_editor? ? super : ""
  end
end
