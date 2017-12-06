format :html do
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
  # override
  # @return [Card] search card on which filtering is based
  def filter_card
    raise Card::Error "filtered search not "
  end

  view :filter_items, template: :haml do
    @filter_format = subformat filter_card
    @item_view = implicit_item_view
    #@filter_form = subformat(filter_card).render_filter_form
  end
end
