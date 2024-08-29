format :html do
  view :demo do
    frame do
      [view_select, wrap_with(:div, view_demo, class: "demo-slot")]
    end
  end

  view :view_list do
    view_list.map do |v|
      wrap_with :p, [content_tag(:h3, v), render(v, show: :menu)]
    end.flatten.join ""
  end

  def view_list
    %i[content titled labeled bar box open closed]
  end

  def demo_view
    Env.params[:demo_view] || :core
  end

  def view_demo
    wrap(true) do
      render demo_view
    end
  end

  def view_select
    card_form :get, success: { view: :demo } do
      select_tag :demo_view,
                 options_for_select(all_views_from_admin_config, demo_view),
                 class: "_submit-on-select"
    end
  end

  def all_views_from_admin_config
    card.all_admin_configs_of_category("views").map(&:codename)
  end

  def all_views
    Card::Set::Format::AbstractFormat::ViewDefinition
      .views.slice(*self.class.ancestors).values.map(&:keys).flatten.uniq.sort
  end
end
