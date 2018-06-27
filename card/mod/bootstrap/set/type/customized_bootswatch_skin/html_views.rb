include_set Abstract::Media
include_set Abstract::BsBadge

format :html do
  view :bar_middle do
    labeled_badge card.item_count, "items"
  end

  view :bar_right do
    edit_button
  end

  view :core, template: :haml do

  end

  before :bar do
    super()
    class_up "bar-middle", "col-3 d-none d-md-flex p-3 border-left d-flex align-items-center p-0", true
  end

  view :bar_left do
    class_up "card-title", "mb-0"
    render :title
  end

  view :bar_bottom do
    listing(card.editable_item_cards, view: :bar).join
  end

  def edit_slot
    haml :edit_slot
  end
end