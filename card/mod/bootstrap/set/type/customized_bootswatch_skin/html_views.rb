include_set Abstract::Media
include_set Abstract::BsBadge

format :html do
  view :menu do
    ""
  end

  def short_content
    ""
    # labeled_badge card.item_count, "items"
    # "#{card.item_count} items"
  end

  view :core, template: :haml do
  end

  bar_cols 9, 3
  infobar_cols 6, 3, 3

  before :bar do
    super()
    voo.show :edit_button, :bar_middle
    class_up "bar-middle", "p-3 align-items-center p-0"
  end

  view :bar_right do
    render(:short_content)
  end

  before :bar_expanded_nav do
    voo.hide :edit_link
  end

  view :bar_bottom do
    render_core
  end
end
