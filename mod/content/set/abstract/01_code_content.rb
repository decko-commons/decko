format :html do
  view :input do
    # Localize
    "Content is stored in file and can't be edited."
  end

  view :bar_middle do
    short_content
  end

  def short_content
    fa_icon("exclamation-circle", class: "text-muted pe-2") +
      wrap_with(:span, "file", class: "text-muted")
  end

  def standard_submit_button
    multi_card_editor? ? super : ""
  end
end
