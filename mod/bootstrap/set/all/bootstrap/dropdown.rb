format :html do
  # Both #dropdown_button and #split_dropdown_button are called with blocks that yield
  # and array of dropdown items.
  #
  # If the item is a string, the only thing added is an li tag.
  #
  # If the item is an Array, it is treated as a list of arguments to #link_to_card,
  # and the "dropdown-item" class is added to each link

  def dropdown_button name, opts={}
    haml :dropdown_button, name: name, items: yield, opts: opts
  end

  def split_dropdown_button main_button
    wrap_with :div, class: "btn-group" do
      [
        main_button,
        split_dropdown_button_toggle,
        dropdown_list(yield, "dropdown-menu-right")
      ]
    end
  end

  def dropdown_header text
    content_tag(:h6, text, class: "dropdown-header")
  end

  def split_dropdown_button_toggle div_attributes={}
    wrap_with :a, div_attributes.reverse_merge(
      href: "#",
      class: "dropdown-toggle #{classy 'dropdown-toggle-split'}",
      "data-bs-toggle" => "dropdown",
      "aria-haspopup" => "true",
      "aria-expanded" => "false"
    ) do
      '<span class="sr-only">Toggle Dropdown</span>'
    end
  end

  private

  def dropdown_list items, extra_css_class=nil
    wrap_with :ul, class: "dropdown-menu #{extra_css_class}", role: "menu" do
      Array.wrap(items).map { |item| dropdown_item item }.compact.join "\n"
    end
  end

  def dropdown_item item
    return unless item.present?
    item = dropdown_item_from_array item if item.is_a? Array
    "<li>#{item}</li>"
  end

  def dropdown_item_from_array array
    array[1] ||= nil
    array[2] ||= {}
    add_class array[2], "dropdown-item"
    link_to_card(*array)
  end
end
