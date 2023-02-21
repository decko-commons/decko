basket[:list_input_options] << "calendar"
basket[:script_calls]["setDatepickerConfig"] = :datepicker_config

format :html do
  def datepicker_config
    Card::Rule.global_setting :datepicker
  end

  def calendar_input
    text_field :content, class: "date-editor datetimepicker-input",
               "type": "date",
               "data-bs-toggle": "datetimepicker",
               "data-bs-target": "##{form_prefix}_content.date-editor"
  end
end
