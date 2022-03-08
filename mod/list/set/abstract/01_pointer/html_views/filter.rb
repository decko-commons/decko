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
      wrap { haml :filtered_list_input }
    end
  end

  def add_item_modal_link
    modal_link "Add Item",
               size: :large,
               class: "btn btn-sm btn-outline-secondary _add-item-link",
               path: { view: :filter_items_modal,
                       slot: { hide: [:modal_footer] },
                       filter: { not_ids: not_ids_value } }
  end

  def filter_items_config
    { "slot-selector": "modal-origin",
      "item-view": filtered_item_view,
      "item-wrap": filtered_item_wrap,
      "item-selector": "._filtered-list-item" }
  end

  def not_ids_value
    card.item_ids.map(&:to_s).join(",")
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
    return unless params[:filter_card]

    Card.fetch params[:filter_card], new: {}
  end
end
