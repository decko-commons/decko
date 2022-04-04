basket[:list_input_options] << "calendar"
basket[:script_config][:datepicker] = "setDatepickerConfig"

format :html do
  def calendar_input
    text_field :content, class: "date-editor datetimepicker-input",
                         "data-bs-toggle": "datetimepicker",
                         "data-bs-target": "##{form_prefix}_content.date-editor"
  end
end
