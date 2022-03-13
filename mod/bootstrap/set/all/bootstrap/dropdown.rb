format :html do
  def dropdown_button name, items_or_opts={}, opts={}
    items = block_given? ? yield : items_or_opts
    opts = items_or_opts if block_given?
    haml :dropdown_button, name: name, items: items, opts: opts
  end

  def split_button main_button, active_item
    wrap_with :div, class: "btn-group" do
      [
        main_button,
        split_button_toggle,
        dropdown_list(yield, "dropdown-menu-right", active_item)
      ]
    end
  end

  private

  # @param items
  #   [String] plain html
  #   [Array<String, Array>] list of item names
  #         If an item is an array then the first element is used as header for a section.
  #         The second item has to be an array with the item names for that section.
  #   [Hash] key is used to identify active item, value is the item name.
  # @param active specifies which item to highlight as active. If items are given as array
  #     it has to be the index of the active item. If items are given as hash it has to be
  #     the key of that item.
  def dropdown_list items, extra_css_class=nil, active=nil
    wrap_with :ul, class: "dropdown-menu #{extra_css_class}", role: "menu" do
      list =
        case items
        when Array
          dropdown_array_list items, active
        when Hash
          dropdown_hash_list items, active
        else
          [items]
        end
      list.flatten.compact.join "\n"
    end
  end

  def dropdown_header text
    content_tag(:h6, text, class: "dropdown-header")
  end

  def dropdown_hash_list items, active=nil
    items.map { |key, item| dropdown_list_item item, key, active }
  end

  def dropdown_array_list items, active=nil
    items.map.with_index { |item, i| dropdown_list_item item, i, active }
  end

  def dropdown_list_item item, active_test, active
    return unless item

    if item.is_a? Array
      formatted_dropdown_list_item item
    else
      simple_dropdown_list_item item, (active_test == active)
    end
  end

  def formatted_dropdown_list_item item
    [dropdown_header(item.first), dropdown_array_list(item.second)]
  end

  def simple_dropdown_list_item item, active
    "<li class='dropdown-item#{' active' if active}'>#{item}</li>"
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
