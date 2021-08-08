include_set Abstract::Pointer

basket[:list_input_options] = [
  "radio",
  "checkbox",
  "select",
  "multiselect",
  "list",
  "filtered list",
  "autocomplete"
]

def content
  basket[:list_input_options].to_pointer_content
end
