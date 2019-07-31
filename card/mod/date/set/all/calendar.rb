Self::InputOptions.add_to_basket :options, "calendar"

format :html do
  def calendar_input
    text_field :content, class: "date-editor datetimepicker-input",
                         "data-toggle": "datetimepicker",
                         "data-target": "##{form_prefix}_content.date-editor"
  end
end
