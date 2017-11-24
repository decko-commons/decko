format :html do
  view :tabs do
    construct_tabs "tabs"
  end

  def construct_tabs tab_type
    tabs = { active: {}, paths: {} }
    voo.items[:view] ||= :content
    card.each_item_name_with_options(_render_raw) do |name, options|
      construct_tab tabs, name, options
    end
    lazy_loading_tabs tabs[:paths], tabs[:active][:name],
                      tabs[:active][:content], type: tab_type
  end

  def construct_tab tabs, name, explicit_options
    tab_options = item_view_options explicit_options
    tabs[:paths][name] = {
      title: nest(name, view: :title, title: tab_options[:title]),
      path: nest_path(name, tab_options).html_safe
    }
    return unless tabs[:active].empty?
    tabs[:active] = { name: name, content: nest(name, tab_options) }
  end

  # def tab_title title, name
  #   return name unless title
  #   name.to_name.title title, @context_names
  # end

  view :pills do
    construct_tabs "pills"
  end

  view :tabs_static do
    construct_static_tabs "tabs"
  end

  view :pills_static do
    construct_static_tabs "pills"
  end

  def construct_static_tabs tab_type
    tabs = {}
    card.item_cards.each do |item|
      tabs[item.name] = nest item, item_view_options(args)
    end
    static_tabs tabs, tab_type
  end
end
