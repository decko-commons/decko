format :html do
  view :filtered_list do
    filtered_list_input
  end

  def filtered_list_input
    haml :filtered_list_input
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

  view :filter_items, template: :haml
end
