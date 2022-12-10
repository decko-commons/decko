format :html do
  # TODO: use CodeFile cards for these
  # builtin layouts allow for rescue / testing
  # HTML_LAYOUTS = Mod::Loader.load_layouts(:html).merge "none" => "{{_main}}"
  # HAML_LAYOUTS = Mod::Loader.load_layouts(:haml)

  def show_with_page_layout view, args
    main!
    layout = page_layout view
    args = main_render_args view, args
    if explicit_modal_wrapper?(view) && layout.to_sym != :modal
      render_outside_of_layout view, args
    else
      render_with_layout view, layout, args
    end
  end

  def page_layout view
    params[:layout] || layout_for_view(view) || layout_name_from_rule || :default
  end

  # for override
  def layout_for_view _view
    nil
  end

  def render_with_layout view, layout, args={}
    view_opts = Layout.main_nest_opts(layout, self)
    view ||= view_opts.delete(:view) || default_page_view
    view_opts[:home_view] = view
    view_opts[:layout] = layout
    render! view, view_opts.reverse_merge(args)
  end

  def default_page_view
    default_nest_view
  end

  def show_layout?
    !Env.ajax? || params[:layout]
  end

  def explicit_modal_wrapper? view
    return unless (wrap_view = view_setting :wrap, view)

    (wrapper_names(wrap_view) & %i[modal bridge]).any?
  end

  private

  def main_render_args view, args
    args[:view] = view if view
    args[:main] = true
    args[:main_view] = true
    args
  end

  def layout_name_from_rule
    card.rule_card(:layout)&.try :first_name
  end

  def render_outside_of_layout view, args
    body = render_with_layout nil, page_layout(view), {}
    body_with_modal body, render!(view, args)
  end

  def body_with_modal body, modal
    if body.include? "</body>"
      # a bit hacky
      # the problem is that the body tag has to be in the layout
      # so that you can add layout css classes like <body class="right-sidebar">
      body.sub "</body>", "#{modal}</body>"
    else
      body + modal
    end
  end

  def wrapper_names wrappers
    case wrappers
    when Hash  then wrappers.keys
    when Array then wrapper_names_from_array wrappers
    else            [wrappers]
    end
  end

  def wrapper_names_from_array wrapper_array
    wrapper_array.map { |w| w.is_a?(Array) ? w.first : w }
  end
end
