format :html do
  view :filtered_list do
    filtered_list_input
  end

  def filtered_list_input
    items = card.item_names context: :raw
    haml :filtered_list_input, items: items, item_view:
  end

  def filtered_list_item item_card
    nest_item item_card do |rendered, item_view|
      wrap_item rendered, item_view
    end
  end

end