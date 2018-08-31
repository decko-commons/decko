format :html do
  # TODO: use CodeFile cards for these
  # builtin layouts allow for rescue / testing
  HTML_LAYOUTS = Mod::Loader.load_layouts(:html).merge "none" => "{{_main}}"
  HAML_LAYOUTS = Mod::Loader.load_layouts(:haml)

  def show_with_page_layout view, args
    args[:view] = view if view
    args[:main] = true
    args[:main_view] = true
    assign_modal_opts view, args unless Env.ajax?
    layout = params[:layout] || layout_name_from_rule || :default
    if explicit_modal_wrapper?(view)
      output [render_with_layout(nil, layout, {}),
              render!(view, args)]
    else
      render_with_layout view, layout, args
    end
    # FIXME: using title because it's a standard view option.  hack!
  end

  def render_with_layout view, layout, args={}
    # @main = false
    view_opts = Layout.main_nest_opts(layout, self)
    view ||= view_opts.delete(:view) || default_nest_view
    view_opts[:layout] = layout
    render! view, view_opts.merge(args)
  end

  def show_layout?
    !Env.ajax? || params[:layout]
  end

  def explicit_modal_wrapper? view
    view_setting(:modal, view) || view_setting(:bridge, view) ||
      (view_setting(:wrap, view) &&
       Array.wrap(view_setting(:wrap, view)).include?(:modal))
  end

  def assign_modal_opts view, args
    return unless (opts = explicit_modal_opts(view) || modal_opts_for_bridge(view))
    @modal_opts = opts.merge args
  end

  def explicit_modal_opts view
    return unless (setting = view_setting(:modal, view))
    setting == true ? { size: :medium } : setting
  end

  def modal_opts_for_bridge view
    return unless view_setting(:bridge, view)
    { size: :full, layout: :modal_bridge }
  end

  def process_haml_layout layout_name
    haml HAML_LAYOUTS[layout_name]
  end

  def process_content_layout layout_name
    content = layout_from_card_or_code layout_name
    process_content content, chunk_list: :references
  end

  def layout_type layout_name
    HAML_LAYOUTS[layout_name.to_s].present? ? :haml : :content
  end

  def layout_name_from_rule
    card.rule_card(:layout)&.try :item_name
  end

  def layout_from_card_or_code name
    layout_card_content(name) || HTML_LAYOUTS[name] || unknown_layout(name)
  end

  def built_in_layouts
    HTML_LAYOUTS.merge(HAML_LAYOUTS).keys.sort.join ", "
  end
end
