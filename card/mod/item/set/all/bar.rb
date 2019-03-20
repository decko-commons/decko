include_set Abstract::BsBadge

format :html do
  setting :bar_cols
  setting :info_bar_cols

  view :info_bar do
    render_bar show: :bar_middle
  end

  view :bar do
    voo.hide :bar_middle
    class_up_bar_sides(voo.show?(:bar_middle))
    # note: above cannot be in `before`, because before blocks run before viz processing
    wrap { haml :bar }
  end

  bar_cols 9, 3
  info_bar_cols 5, 4, 3

  view :expanded_bar do
    class_up_bar_sides(false)
    wrap { haml :expanded_bar }
  end

  view :expanded_edit_bar, perms: :none do
    _render_expanded_bar!
  end

  before(:bar) { bar_classes }
  before(:expanded_bar) { bar_classes }

  def bar_classes
    shared = "align-items-center"
    class_up "bar-left", "d-flex p-2 font-weight-bold grow-2 #{shared}"
    class_up "bar-middle", "d-none d-md-flex p-2 border-left text-align-middle #{shared}"
    class_up "bar-right",
             "d-flex p-2 border-left justify-content-end text-align-right #{shared}"
  end

  def class_up_bar_sides middle
    class_up "bar-left", "col-#{bar_cols[0]}"
    class_up "bar-right", "col-#{bar_cols[1]}"
    return unless middle

    class_up "bar-left", "col-md-#{info_bar_cols[0]}"
    class_up "bar-middle", "col-md-#{info_bar_cols[1]}"
    class_up "bar-right", "col-#{info_bar_cols[1]}"
  end

  view :bar_left do
    class_up "card-title", "mb-0"
    if voo.show?(:toggle)
      link_to_view :expanded_bar, render_title
    else
      render_title
    end
  end

  view :bar_expanded_left do
    class_up "card-title", "mb-0"
    link_to_view :bar, render_title
  end

  # view :bar_expanded_right do
  #   class_up "card-title", "mb-0"
  #   render :bar_right, optional: :show
  # end

  view :bar_right do
    [(render(:short_content) unless voo.show?(:bar_middle)),
     render(:edit_button, optional: :hide)]
  end

  view :bar_middle do
    render :short_content
  end

  view :bar_bottom do
    if nest_mode == :edit
      render :edit
    else
      render :core
    end
  end

  view :bar_nav, wrap: { div: { class: "bar-nav d-flex" } } do
    [render(:bar_page_link, optional: :hide), render_bar_expand_link]
  end

  view :bar_expanded_nav, wrap: { div: { class: "bar-nav d-flex" } } do
    [render_edit_link, render_bar_page_link, render_bar_collapse_link]
  end

  view :bar_page_link do
    class_up "full-page-link", "pl-2 text-muted"
    full_page_link
  end

  def toggle_class
    "btn btn-sm btn-outline-secondary p-0 border-0 rounded-0"
  end

  view :bar_expand_link do
    link_to_view :expanded_bar, icon_tag(:play_arrow), class: toggle_class
  end

  view :bar_collapse_link do
    link_to_view :bar, icon_tag(:arrow_drop_down, class: "md-24"), class: toggle_class
  end

  view :edit_button do
    link_to_view :edit, "Edit", class: "btn btn-sm btn-outline-primary mr-2"
  end
end
