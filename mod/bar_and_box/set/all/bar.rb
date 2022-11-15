format :html do
  setting :bar_cols
  setting :mini_bar_cols

  bar_cols 9, 3
  mini_bar_cols 9, 3

  view :bar, unknown: :mini_bar do
    cols = bar_cols.size == 3 ? [mini_bar_cols, bar_cols] : [bar_cols]
    prepare_bar(*cols)
    build_bar
  end

  view :mini_bar, unknown: true do
    prepare_bar mini_bar_cols
    build_bar
  end

  view(:bar_left, unknown: true) { render_title }
  view(:bar_middle, unknown: :blank) { "" }
  view(:bar_right, unknown: :blank) { "" }

  view :bar_bottom do
    view = nest_mode == :edit ? :edit : :content
    render view, home_view: view
  end

  view :bar_menu, unknown: true, template: :haml
  view :bar_body, unknown: true, template: :haml

  view :accordion_bar, unknown: :mini_bar do
    build_accordion_bar
  end
  view :closed_bar, :accordion_bar

  view :open_bar do
    build_accordion_bar open: true
  end
  view :expanded_bar, :open_bar

  def build_accordion_bar open: false
    prepare_bar mini_bar_cols
    class_up "accordion-item", "bar #{classy 'bar'}"
    accordion_item render_bar_body,
                   subheader: render_menu,
                   body: render_bar_bottom,
                   open: open,
                   context: :accordion_bar
  end

  def build_bar
    wrap { haml :bar }
  end

  def bar_menu_items
    [
      full_page_link(text: "page"),
      modal_page_link(text: "modal"),
      edit_link(:edit, text: card.new? ? "create" : "edit"),
      bridge_link(text: "advanced")
    ]
  end

  # NOTE: currently bar always turns to mini-bar at md
  def prepare_bar two_cols, three_cols=nil
    class_up "bar", full_page_card.safe_set_keys
    class_up_cols %w[bar-left bar-right], two_cols
    class_up "bar-middle", "d-none d-md-flex"
    if three_cols
      class_up_cols %w[bar-left bar-middle bar-right], three_cols, "md"
    else
      voo.hide :bar_middle
    end
  end

  def class_up_cols classes, cols, context=nil
    classes.each_with_index do |cls, i|
      class_up cls, ["col", context, cols[i]].compact.join("-")
    end
  end

  def bar_wrap_data
    full_page_card == card ? wrap_data : full_page_card.format.wrap_data
  end
end
