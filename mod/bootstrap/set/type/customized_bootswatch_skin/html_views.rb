include_set Abstract::Media
include_set Abstract::BsBadge

format :html do
  view :menu do
    ""
  end

  def short_content
    ""
  end

  view :core, template: :haml

  bar_cols 6, 3, 3

  before :bar do
    class_up "bar-middle", "p-3 align-items-center p-0"
  end

  view :bar_right do
    render(:short_content)
  end

  view :bar_bottom do
    render_core
  end
end
