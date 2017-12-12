

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

  # for override
  # @return [Card] search card on which filtering is based
  def filter_card
    fcard = card.options_rule_card || Card[:all]
    return fcard if fcard.respond_to? :wql_hash
    fcard.fetch trait: :referred_to_by, new: {}
  end
  
  view :filter_items, template: :haml
end
