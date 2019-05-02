format :html do
  # TODO: use CodeFile cards for these
  # builtin layouts allow for rescue / testing
  # HTML_LAYOUTS = Mod::Loader.load_layouts(:html).merge "none" => "{{_main}}"
  # HAML_LAYOUTS = Mod::Loader.load_layouts(:haml)

  def show_with_page_layout view, args
    main!
    args = main_render_args view, args
    if explicit_modal_wrapper?(view) && page_layout.to_sym != :modal
      render_outside_of_layout view, args
    else
      render_with_layout view, page_layout, args
    end
  end

  def main_render_args view, args
    args[:view] = view if view
    args[:main] = true
    args[:main_view] = true
    args
  end

  def page_layout
    params[:layout] || layout_name_from_rule || :default
  end

  def render_with_layout view, layout, args={}
    view_opts = Layout.main_nest_opts(layout, self)
    view ||= view_opts.delete(:view) || default_nest_view
    view_opts[:layout] = layout
    render! view, view_opts.reverse_merge(args)
  end

  def render_outside_of_layout view, args
    body = render_with_layout(nil, page_layout, {})
    modal = render!(view, args)
    if body.include?("</body>")
      # a bit hacky
      # the problem is that the body tag has to be in the layout
      # so that you can add layout css classes like <body class="right-sidebar">
      body.sub!("</body>", "#{modal}</body>")
    else
      body += modal
    end
    body
  end

  def show_layout?
    !Env.ajax? || params[:layout]
  end

  def explicit_modal_wrapper? view
    return unless view_setting(:wrap, view)

    wrapper_names(view_setting(:wrap, view)).any? { |n| n == :modal || n == :bridge }
  end

  def wrapper_names wrappers
    case wrappers
    when Hash  then wrappers.keys
    when Array then wrappers.map { |w| w.is_a?(Array) ? w.first : w }
    else            [wrappers]
    end
  end

  def layout_name_from_rule
    card.rule_card(:layout)&.try :item_name
  end
end
