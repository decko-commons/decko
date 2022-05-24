format :html do
  view :core, cache: :never do
    standard_pointer_core
  end

  view :item_cores, cache: :never do
    card.known_item_cards.map do |item|
      nest item, view: :core
    end.join "\n"
  end

  def standard_pointer_core
    with_paging do |paging_args|
      wrap_with :div,
                class: "card-list card-list-#{item_view_options[:view]} pointer-list" do
        standard_pointer_items(paging_args)
      end
    end
  end

  def standard_pointer_items paging_args
    pointer_items(paging_args.extract!(:limit, :offset)).join(voo.separator || "\n")
  end

  view :one_line_content do
    item_view = implicit_item_view
    item_view = item_view == "name" ? "name" : "link"
    wrap_with :div, class: "pointer-list one-line-pointer-list" do
      # limit to first 10 items to optimize
      pointer_items(view: item_view, limit: 10, offset: 0).join ", "
    end
  end

  def wrap_item rendered, item_view
    %(<div class="pointer-item item-#{item_view}">#{rendered}</div>)
  end

  view :input do
    _render_hidden_content_field + super()
  end

  def default_input_type
    :list
  end

  view :list, cache: :never do
    list_input
  end

  def list_input args={}
    items = items_for_input args[:item_list]
    extra_class = "pointer-list-ul"
    ul_classes = classy "pointer-list-editor", extra_class
    haml :list_input, items: items, ul_classes: ul_classes,
                      options_card: options_card_name
  end

  %i[autocomplete checkbox radio select multiselect].each do |editor_view|
    view(editor_view) { send "#{editor_view}_input" }
  end

  def autocomplete_input
    autocomplete_field items_for_input.first, options_card_name
  end

  def checkbox_input
    raw haml(:checkbox_input, submit_on_change: @submit_on_change)
  end

  def radio_input
    raw haml(:radio_input, submit_on_change: @submit_on_change)
  end

  def select_input
    options = { "-- Select --" => "" }.merge card.options_hash
    select_tag("pointer_select-#{unique_id}",
               options_for_select(options, card.item_name),
               class: "pointer-select form-control")
  end

  def bar_select_input
    raw haml(:click_select_input, item_view: :bar, multiselect: false)
  end

  def box_select_input
    raw haml(:click_select_input, item_view: :box, multiselect: false)
  end

  def bar_multiselect_input
    raw haml(:click_select_input, item_view: :bar, multiselect: true)
  end

  def box_multiselect_input
    raw haml(:click_select_input, item_view: :box, multiselect: true)
  end

  def multiselect_input
    select_tag "pointer_multiselect-#{unique_id}",
               options_for_select(card.options_hash, card.item_names),
               multiple: true, class: "pointer-multiselect form-control"
  end

  def one_line_content
    if count == 1
      card.first_name
    else
      short_content
    end
  end

  private

  # currently only used by :list and :autocomplete. could be generalized?
  def items_for_input items=nil
    items ||= card.item_names context: :raw
    items.empty? ? [""] : items
  end
end
