format :html do
  setting :bar_cols
  setting :mini_bar_cols

  bar_cols 9, 3
  mini_bar_cols 9, 3

  view :bar, unknown: :mini_bar do
    cols = bar_cols.size == 3 ? [mini_bar_cols, bar_cols] : [bar_cols]
    bar(*cols)
  end

  view :mini_bar, unknown: true do
    bar mini_bar_cols
  end

  view(:bar_left, unknown: true) { bar_title }
  view(:bar_middle, unknown: :blank) { "" }
  view(:bar_right, unknown: :blank) { "" }

  view :bar_bottom do
    render(nest_mode == :edit ? :edit : :core)
  end

  view :bar_menu, unknown: true, template: :haml

  def bar_menu_items
    [
      edit_link(:edit, text: "edit"),
      full_page_link(text: "full page"),
      bridge_link(text: "advanced")
    ]
  end

  def bar_title
    card.unknown? ? render_missing : render_title
  end

  def bar two_cols, three_cols=nil
    class_up "bar", full_page_card.safe_set_keys
    class_up_cols %w[bar-left bar-right], two_cols
    if three_cols
      class_up_cols %w[bar-left bar-middle bar-right], three_cols, "md"
    else
      voo.hide :bar_middle
    end
    wrap { haml :bar }
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
