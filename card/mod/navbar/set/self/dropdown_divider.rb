format :html do
  view :nav_item do
    wrap_with :div, "", class: "dropdown-divider"
  end

  view :nav_link_in_dropdown do
    wrap_with :div, "", class: "dropdown-divider"
  end
end
