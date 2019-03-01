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

  before :bar do
    super()
    voo.show :edit_button
    class_up "bar-middle",
             "col-3 d-none d-md-flex p-3 border-left d-flex align-items-center p-0",
             true
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
