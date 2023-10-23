format :html do
  view :nav_item do
    wrap_with_nav_item nav_dropdown
  end

  def nest_item_array
    card.item_cards.map do |item|
      nest_item item, view: :core
    end
  end
end
