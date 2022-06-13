format :html do
  def dropdown_button name, items_or_opts={}, opts={}
    items = block_given? ? yield : items_or_opts
    opts = items_or_opts if block_given?
    haml :dropdown_button, name: name, items: items, opts: opts
  end

  def split_button main_button
    wrap_with :div, class: "btn-group" do
      [
        main_button,
        split_button_toggle,
        dropdown_list(yield, "dropdown-menu-right")
      ]
    end
  end

  def dropdown_header text
    content_tag(:h6, text, class: "dropdown-header")
  end

  private

  # @param items
  #   [String] plain html
  #   [Array<String, Array>] list of item names
  #         If an item is an array then the first element is used as header for a section.
  #         The second item has to be an array with the item names for that section.
  #   [Hash] key is used to identify active item, value is the item name.
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

  def split_button_toggle
    wrap_with :a,
              href: "#",
              class: "nav-link ps-0 dropdown-toggle dropdown-toggle-split",
              "data-bs-toggle" => "dropdown",
              "aria-haspopup" => "true",
              "aria-expanded" => "false" do
      '<span class="sr-only">Toggle Dropdown</span>'
    end
  end
end
