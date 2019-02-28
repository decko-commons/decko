include_set Abstract::BsBadge

format :html do
  view :mini_bar do
    render_bar hide: [:bar_middle, :bar_nav]
  end

  view :bar do
    class_up_bar_sides(*bar_side_cols(voo.show?(:bar_middle)))
    # note: above cannot be in `before`, because before blocks run before viz processing
    wrap { haml :bar }
  end

  def bar_side_cols middle=true
    middle ? [5, 4, 3] : [10, 2]
  end

  view :expanded_bar do
    class_up_bar_sides(*bar_side_cols(false))
    wrap { haml :expanded_bar }
  end

  view :expanded_edit_bar, perms: :none do
    _render_expanded_bar!
  end

  before(:bar) { bar_classes }
  before(:expanded_bar) { bar_classes }

  def bar_classes
    shared = "align-items-center"
    class_up "bar-left", "p-2 font-weight-bold d-flex grow-2 #{shared}"
    class_up "bar-middle", "d-none d-md-flex p-2 border-left text-align-middle #{shared}"
    class_up "bar-right",
             "p-2 border-left d-flex justify-content-end text-align-right #{shared}"
  end

  def class_up_bar_sides *sizes
    left = sizes.shift
    right = sizes.pop
    class_up "bar-left", "col-#{left}", true
    class_up "bar-middle", "col-#{sizes.first}", true if sizes.any?
    class_up "bar-right", "col-#{right}", true
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

  view :bar_expanded_right do
    class_up "card-title", "mb-0"
    render :bar_expanded_nav, optional: :show
  end

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
    [render_bar_page_link, render_bar_expand_link]
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
