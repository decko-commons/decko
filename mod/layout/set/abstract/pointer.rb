include_set Abstract::Items

format :html do
  def navbar_items view: :nav_item, link_class: nil
    card.item_cards.map do |item_card|
      item = nest item_card, view: view
      view == :nav_item ? wrap_with_nav_item(item) : item
    end
  end
end
