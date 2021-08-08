include_set Abstract::Pointer

basket[:options] = [
  "radio",
  "checkbox",
  "select",
  "multiselect",
  "list",
  "filtered list",
  "autocomplete"
]

def content
  basket[:options].to_pointer_content
end
