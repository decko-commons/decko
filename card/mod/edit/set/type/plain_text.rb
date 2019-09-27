format :html do
  def input_type_content_options
    ["text area", "text field", "ace editor"]
  end
end

def field_settings
  %i[default help input_type]
end

def show_input_type?
  true
end
