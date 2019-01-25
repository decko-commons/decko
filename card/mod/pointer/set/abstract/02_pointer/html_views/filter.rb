format :html do
  view :filtered_list, tags: :unknown_ok do
    filtered_list_input
  end

  view :filter_items_modal, tags: :unknown_ok, cache: :never, wrap: :modal do
    render_filter_items
  end

  view :filter_items, tags: :unknown_ok, cache: :never, wrap: :slot  do
    haml :filter_items
  end

  def filtered_list_input
    with_nest_mode :normal do
      class_up "card-slot", filtered_list_slot_class, true
      with_class_up "card-slot", filtered_list_slot_class, true do
        wrap do
          haml :filtered_list_input
        end
      end
    end
  end

  def add_selected_link
    link_to "Add Selected",
            path: { item: params[:item], filter_card: params[:filter_card] },
            class: "_add-selected slotter _close-modal btn btn-primary disabled",
            data: { "slot-selector": ".#{params[:slot_selector]}",
                    "item-selector": ".#{params[:item_selector]}",
                    remote: true }
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
    fcard = card.options_rule_card || Card[:all]
    return fcard if fcard.respond_to? :wql_hash

    fcard.fetch trait: :referred_to_by, new: {}
  end

  def filter_card_from_params
    return unless params[:filter_card]
    Card.fetch params[:filter_card], new: {}
  end

  # currently actually used as a class
  # (because we don't have api to override slot's id)
  def filtered_list_slot_class
    @filtered_list_slot_class ||= "filtered-list-#{unique_id}"
  end
end
