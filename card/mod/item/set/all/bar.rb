include_set Abstract::BsBadge

format :html do
  view :thin_bar do
    render_bar hide: :bar_middle
  end

  view :bar do
    wrap { haml :bar }
  end

  view :expanded_bar do
    wrap { haml :expanded_bar }
  end

  view :bar_left do
    class_up "card-title", "mb-0"
    render :title
  end

  view :bar_right do
    ""
  end

  view :bar_middle do
    labeled_badge stat_number, stat_label
  end

  view :bar_bottom do
    if mode == :edit
      render :edit
    else
      render :core
    end
  end

  def stat_number
    card.content.lines.count
  end

  def stat_label
    stat_number == 1 ? "line" : "lines"
  end

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
end
