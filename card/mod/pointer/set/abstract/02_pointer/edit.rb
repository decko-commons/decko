format :html do
  view :editor do |args|
    # FIXME: use voo
    @item_list = args[:item_list]
    @extra_css_class = args[:extra_css_class]
    _render_hidden_content_field + super()
    # .merge(pointer_item_class: 'form-control')))
  end

  def default_editor
    :list
  end

  view :list, cache: :never do |args|
    list_input args
  end

  def list_input args={}
    items = items_for_input args[:item_list]
    extra_class = args[:extra_css_class] || "pointer-list-ul"
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

  view :list_item, template: :haml do |args|
    @item = args[:pointer_item]
    @options_card ||= options_card_name
  end

  view :autocomplete do |_args|
    autocomplete_input
  end

  def items_for_input items
    items ||= card.item_names context: :raw
    items.empty? ? [""] : items
  end

  def autocomplete_input
    items = items_for_input @item_list
    haml :autocomplete_input, item: items.first, options_card: options_card_name
  end

  view :checkbox do |_args|
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

  view :multiselect do |_args|
    multiselect_input
  end

  def multiselect_input
    select_tag(
      "pointer_multiselect-#{unique_id}",
      options_for_select(card.option_names, card.item_names),
      multiple: true, class: "pointer-multiselect form-control"
    )
  end

  view :radio do |_args|
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

  view :select do |_args|
    select_input
  end

  def select_input
    options = [["-- Select --", ""]] + card.option_names.map { |x| [x, x] }
    select_tag("pointer_select-#{unique_id}",
               options_for_select(options, card.item_names.first),
               class: "pointer-select form-control")
  end

  view :filtered_list do
    filtered_list_input
  end

  def filtered_list_input
    items = card.item_names context: :raw
    haml :filtered_list_input, items: items
  end

  def filtered_list_item item_card
    nest_item item_card do |rendered, item_view|
      wrap_item rendered, item_view
    end
  end
end
