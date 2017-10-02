event :add_and_drop_items, :prepare_to_validate, on: :save do
  adds = Env.params["add_item"]
  drops = Env.params["drop_item"]
  Array.wrap(adds).each { |i| add_item i } if adds
  Array.wrap(drops).each { |i| drop_item i } if drops
end

event :insert_item_event, :prepare_to_validate,
      on: :save, when: proc { Env.params["insert_item"] } do
  index = Env.params["item_index"] || 0
  insert_item index.to_i, Env.params["insert_item"]
end

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
    @item_list = args[:item_list]
    @extra_css_class = args[:extra_css_class]
    list_input
  end

  def list_input
    items = @item_list || card.item_names(context: :raw)
    items = [""] if items.empty?
    rendered_items = items.map do |item|
      _render_list_item pointer_item: item
    end.join "\n"
    extra_css_class = @extra_css_class || "pointer-list-ul"

    raw(<<-HTML
      <ul class="pointer-list-editor #{extra_css_class}"
          data-options-card="#{options_card_name}">
        #{rendered_items}
      </ul>
      #{add_item_button}
    HTML
    )
  end

  def options_card_name
    (oc = card.options_rule_card) ? oc.cardname.url_key : ":all"
  end

  def add_item_button
    wrap_with :span, class: "input-group" do
      button_tag class: "pointer-item-add" do
        glyphicon("plus") + " add another"
      end
    end
  end

  view :list_item do |args|
    <<-HTML
      <li class="pointer-li mb-1">
        <span class="input-group">
          <span class="input-group-addon handle">
            #{icon_tag :reorder}
          </span>
          #{text_field_tag 'pointer_item', args[:pointer_item],
                           class: 'pointer-item-text form-control'}
          <span class="input-group-btn">
            <button class="pointer-item-delete btn btn-secondary" type="button">
              #{icon_tag :remove}
            </button>
          </span>
        </span>
      </li>
    HTML
  end

  view :autocomplete do |args|
    autocomplete_input
  end

  def autocomplete_input
    items = @item_list || card.item_names(context: :raw)
    items = [""] if items.empty?
    <<-HTML
      <div class="pointer-list-editor pointer-list-ul"
          data-options-card="#{options_card_name}">
        #{text_field_tag 'pointer_item', items.first,
                         class: 'pointer-item-text form-control'}
      </div>
    HTML
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

  def option_label option_name, id
    %(<label for="#{id}">#{option_label_text option_name}</label>)
  end

  def option_label_text option_name
    o_card = Card.fetch(option_name)
    (o_card && o_card.label) || option_name
  end

  # @param option_type [String] "checkbox" or "radio"
  def option_description option_type, option_name
    return "" unless (description = pointer_option_description(option_name))
    %(<div class="#{option_type}-option-description">#{description}</div>)
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

  def pointer_option_description option
    pod_name = card.rule(:options_label) || "description"
    dcard = Card["#{option}+#{pod_name}"]
    return unless dcard && dcard.ok?(:read)
    with_nest_mode :normal do
      subformat(dcard).render_core
    end
  end
end

def items= array
  self.content = ""
  array.each { |i| self << i }
  save!
end

def << item
  newname =
    case item
    when Card    then item.name
    when Integer then (c = Card[item]) && c.name
    else              item
    end
  add_item newname
end

def add_item name, allow_duplicates=false
  return if !allow_duplicates && include_item?(name)
  self.content = "[[#{(item_names << name).reject(&:blank?) * "]]\n[["}]]"
end

def add_item! name
  add_item(name) && save!
end

def drop_item name
  return unless include_item? name
  key = name.to_name.key
  new_names = item_names.reject { |n| n.to_name.key == key }
  self.content = new_names.empty? ? "" : "[[#{new_names * "]]\n[["}]]"
end

def drop_item! name
  drop_item name
  save!
end

def insert_item index, name
  new_names = item_names
  new_names.delete name
  new_names.insert index, name
  self.content = new_names.map { |new_name| "[[#{new_name}]]" }.join "\n"
end

def insert_item! index, name
  insert_item index, name
  save!
end

def option_names
  result_names = configured_option_names

  if (selected_options = item_names)
    result_names += selected_options
    result_names.uniq!
  end
  result_names
end

def configured_option_names
  if (oc = options_rule_card)
    oc.item_names context: name,
                  limit: oc.respond_to?(:default_limit) ? oc.default_limit : 0
  else
    Card.search({ sort: "name", limit: 50, return: :name },
                "option names for pointer: #{name}")
  end
end

def option_cards
  option_names.map do |name|
    Card.fetch name, new: {}
  end
end
