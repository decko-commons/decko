include_set Abstract::BsBadge

format :html do
  setting :bar_cols
  setting :info_bar_cols

  view :info_bar do
    render_bar show: :bar_middle
  end

  before :bar do
    class_up "bar", card.safe_set_keys
    voo.hide! :bar_collapse_link
    voo.hide :edit_link, :full_page_link, :bridge_link
  end

  view :bar do
    voo.hide :bar_middle
    voo.hide :bar_bottom # needed for toggle
    class_up_bar_sides(voo.show?(:bar_middle))
    # note: above cannot be in `before`, because before blocks run before viz processing
    wrap { haml :bar }
  end

  bar_cols 9, 3
  info_bar_cols 5, 4, 3

  before :expanded_bar do
    class_up "bar", card.safe_set_keys
    voo.hide! :bar_expand_link
  end

  view :expanded_bar do
    class_up_bar_sides(false)
    wrap { haml :expanded_bar }
  end

  def class_up_bar_sides middle
    class_up_cols %w[bar-left bar-right], bar_cols
    class_up_cols %w[bar-left bar-middle bar-right], info_bar_cols, "md" if middle
  end

  def class_up_cols classes, cols, context=nil
    classes.each_with_index do |cls, i|
      class_up cls, ["col", context, cols[i]].compact.join("-")
    end
  end

  view :bar_left do
    bar_title
  end

  def bar_title
    if voo.show?(:toggle)
      link_to_view bar_title_toggle_view, render_title
    else
      render_title
    end
  end

  def bar_title_toggle_view
    voo.show?(:bar_bottom) ? :bar : :expanded_bar
  end

  view :bar_right do
    [(render(:short_content) unless voo.show?(:bar_middle)),
     render(:edit_button, optional: :hide)]
  end

  view :bar_middle do
    render :short_content
  end

  view :bar_bottom do
    render(nest_mode == :edit ? :edit : :core)
  end

  view :bar_nav, wrap: { div: { class: "bar-nav" } } do
    [render_bar_expand_link,
     render_bar_collapse_link,
     render_full_page_link,
     render_edit_link,
     render_bridge_link]
  end

  view :bar_expand_link do
    link_to_view :expanded_bar, icon_tag(:keyboard_arrow_down)
  end

  view :bar_collapse_link do
    link_to_view :bar, icon_tag(:keyboard_arrow_up)
  end

  view :edit_button do
    link_to_view :edit, "Edit", class: "btn btn-sm btn-outline-primary mr-2"
  end
end
