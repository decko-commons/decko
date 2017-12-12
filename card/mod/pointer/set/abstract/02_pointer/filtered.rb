

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
    return Card[:all] unless (options_card = card.options_rule_card)
    if options_card.respond_to? :wql_hash
      options_card
    else
      options_card.fetch trait: :referred_to_by
    end
  end

  view :filter_items, template: :haml
end
