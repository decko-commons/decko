basket[:list_input_options] = [
  "radio",
  "checkbox",
  "select",
  "multiselect",
  "list",
  "filtered list",
  "autocomplete"
]

def supports_content_options?
  false
end

def supports_content_option_view?
  false
end

format :html do
  wrapper :filtered_list_item, template: :haml do
    haml :filtered_list_item
  end
end
