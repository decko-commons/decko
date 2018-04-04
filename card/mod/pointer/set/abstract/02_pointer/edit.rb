format :html do
  view :editor do
    _render_hidden_content_field + super()
  end

  def default_editor
    :list
  end

  view :list, cache: :never do
    list_input
  end

  def list_input args={}
    items = items_for_input args[:item_list]
    extra_class = "pointer-list-ul"
    ul_classes = classy "pointer-list-editor", extra_class
    haml :list_input, items: items, ul_classes: ul_classes
  end

  def add_item_button
    wrap_with :span, class: "input-group" do
      button_tag class: "pointer-item-add" do
        glyphicon("plus") + " add another"
      end
    end
  end

  def edit_list_item item
    haml :list_item, pointer_item: item, options_card: options_card_name
  end

  view :autocomplete do
    autocomplete_input
  end

  def items_for_input items
    items ||= card.item_names context: :raw
    items.empty? ? [""] : items
  end

  def autocomplete_input
    items = items_for_input
    haml :autocomplete_input, item: items.first, options_card: options_card_name
  end

  view :checkbox do
    checkbox_input
  end

  def checkbox_input
    options = card.option_names.map do |option_name|
      checked = card.item_names.include?(option_name)
      id = "pointer-checkbox-#{option_name.to_name.key}"
      <<-HTML
        <div class="pointer-checkbox">
          #{check_box_tag "pointer_checkbox-#{unique_id}", option_name, checked,
                          id: id, class: 'pointer-checkbox-button'}
          #{option_label option_name, id}
          #{option_description 'checkbox', option_name}
        </div>
      HTML
    end.join "\n"

    raw %(<div class="pointer-checkbox-list">#{options}</div>)
  end

  view :multiselect do
    multiselect_input
  end

  def multiselect_input
    select_tag(
      "pointer_multiselect-#{unique_id}",
      options_for_select(card.option_names, card.item_names),
      multiple: true, class: "pointer-multiselect form-control"
    )
  end

  view :radio do
    radio_input
  end

  def radio_input
    input_name = "pointer_radio_button-#{card.key}"
    options = card.option_names.map do |option_name|
      checked = (option_name == card.item_names.first)
      id = "pointer-radio-#{option_name.to_name.key}"
      <<-HTML
        <li class="pointer-radio radio">
          #{radio_button_tag input_name, option_name, checked,
                             id: id, class: 'pointer-radio-button'}
          #{option_label option_name, id}
          #{option_description 'radio', option_name}
        </li>
      HTML
    end.join("\n")
    options = "no options" if options.empty?

    raw %(<ul class="pointer-radio-list">#{options}</ul>)
  end

  view :select do
    select_input
  end

  def select_input
    options = [["-- Select --", ""]] + card.option_names.map { |x| [x, x] }
    select_tag("pointer_select-#{unique_id}",
               options_for_select(options, card.item_names.first),
               class: "pointer-select form-control")
  end
end
