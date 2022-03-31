format :html do
  view :filtered_list, unknown: true do
    filtered_list_input
  end

  view :filter_items_modal, unknown: true, wrap: :modal do
    render_filter_items
  end

  view :filter_items, unknown: true, wrap: :slot, template: :haml

  # for override
  def allow_duplicates?
    false
  end

  def filtered_item_view
    implicit_item_view
  end

  def filtered_item_wrap
    :filtered_list_item
  end

  def filtered_list_input
    with_nest_mode :normal do
      haml :filtered_list_input
    end
  end

  def add_item_modal_link text=nil
    modal_link (text || "Add Item"),
               size: :large,
               class: "btn btn-sm btn-outline-secondary _add-item-link",
               path: {
                 view: :filter_items_modal,
                 slot: { hide: [:modal_footer] },
                 filter: filter_items_default_filter,
                 # each key value below is there to help support new cards configured
                 # by type_plus_right sets. do not remove without testing that case
                 # (not currently covered by specs)
                 type: :list.cardname,
                 filter_card: filter_card.name,
                 filter_items: filter_item_config
               }
  end

  def filter_items_default_filter
    { not_ids: not_ids_value }
  end

  def filter_items_data
    {
      "slot-selector": "modal-origin",
      "item-selector": "._filtered-list-item",
      item: filter_item_config
    }
  end

  def filter_item_config
    %i[view wrap duplicable].each_with_object({}) do |key, hash|
      hash[key] = params.dig(:filter_items, key) || send("filtered_item_#{key}")
    end
  end

  def filtered_item_duplicable
    false
  end

  def not_ids_value
    filtered_item_duplicable ? "" : card.item_ids.map(&:to_s).join(",")
  end

  view :add_selected_link, unknown: true do
    button_tag "Add Selected", class: "_add-selected btn btn-primary", disabled: true
  end

  def filtered_list_item item_card
    nest_item item_card do |rendered, item_view|
      wrap_item rendered, item_view
    end
  end

  # for override
  # @return [Card] search card on which filtering is based
  def filter_card
    filter_card_from_params || default_filter_card
  end

  def default_filter_card
    fcard = card.options_card
    return fcard if fcard.respond_to? :cql_hash

    fcard.fetch :referred_to_by, new: {}
  end

  def filter_card_from_params
    return unless params[:filter_card]&.present?

    Card.fetch params[:filter_card], new: {}
  end
end
