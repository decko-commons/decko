include_set Abstract::Media
include_set Abstract::BsBadge

format :html do
  view :bar_middle do
    labeled_badge card.item_count, "items"
  end

  view :bar_right do
    edit_button
  end

  def edit_button
    link_to_view :edit, "Edit",
                 class: "btn btn-sm btn-outline-primary slotter"
  end

  view :bar_left do
    class_up "card-title", "mb-0"
    render :title
  end

  view :bar_bottom do
    listing(card.editable_item_cards, view: :bar).join
  end
end