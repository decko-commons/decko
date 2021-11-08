include_set Abstract::Items

format :html do
  def navbar_items view: :nav_item, **_args
    card.item_cards.map do |item_card|
      nest item_card, view: view
    end
  end
end
