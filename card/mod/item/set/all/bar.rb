include_set Abstract::BsBadge

format :html do
  view :mini_bar do
    shared = "align-items-center"
    mini_class = "col-5 border-left d-flex justify-content-end text-align-right #{shared}"
    class_up "bar-left", "col-7 p-2 font-weight-bold d-flex grow-2 #{shared}"
    class_up "bar-right", mini_class
    render_bar hide: :bar_middle
  end

  view :bar do
    wrap { haml :bar }
  end

  view :expanded_bar do
    wrap { haml :expanded_bar }
  end

  view :expanded_edit_bar, perms: :none do
    _render_expanded_bar!
  end

  before :bar do
    shared = "align-items-center"
    class_up "bar-left", " col-5 p-2 font-weight-bold d-flex grow-2 #{shared}"
    class_up "bar-middle", "col-4 d-none d-md-flex p-3 border-left #{shared}"
    class_up "bar-right",
             "col-3 p-3 border-left d-flex justify-content-end text-align-right #{shared}"
  end

  view :bar_left do
    class_up "card-title", "mb-0"
    render :title
  end

  view :bar_right do
    render :edit_button, optional: :hide
  end

  view :bar_middle do
    ""
  end

  view :bar_bottom do
    if nest_mode == :edit
      render :edit
    else
      render :core
    end
  end

  # def stat_number
  #   card.content.lines.count
  # end
  #
  # def stat_label
  #   stat_number == 1 ? "line" : "lines"
  # end

  view :bar_page_link do
    link_to_card card, icon_tag(:open_in_new), class: "text-muted"
  end

  def toggle_class
    "slotter btn btn-sm btn-outline-secondary p-0 border-0 rounded-0"
  end

  view :bar_expand_link do
    link_to_view :expanded_bar, icon_tag(:play_arrow), class: toggle_class
  end

  view :bar_collapse_link do
    link_to_view :bar, icon_tag(:arrow_drop_down, class: "md-24"), class: toggle_class
  end

  view :edit_button do
    link_to_view :edit, "Edit",
                 class: "btn btn-sm btn-outline-primary slotter mr-2"
  end
end
