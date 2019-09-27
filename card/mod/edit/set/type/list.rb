def input_type_content_options
  ["multiselect", "checkbox", "autocompleted list", "filtered list"]
end

def show_content_options?
  true
end

def show_input_type?
  true
end

def field_settings
  %i[default help input_type content_options content_option_view]
end
