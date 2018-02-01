include_set Abstract::Pointer

basket :options
add_to_basket :options, "radio"
add_to_basket :options, "checkbox"
add_to_basket :options, "select"
add_to_basket :options, "multiselect"
add_to_basket :options, "list"
add_to_basket :options, "filtered list"

def content
  options.to_pointer_content
end
