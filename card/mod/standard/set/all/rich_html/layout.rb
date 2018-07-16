
# nest({ wikipedia: { editable: false, type: :phrase, default: "dfds" }}, :about, :address)

format :html do
  # TODO: use CodeFile cards for these
  # builtin layouts allow for rescue / testing
  HTML_LAYOUTS = Mod::Loader.load_layouts(:html).merge "none" => "{{_main}}"
  HAML_LAYOUTS = Mod::Loader.load_layouts(:haml)

  def show_without_page_layout view, args
    @main = true if params[:is_main] || args[:main]
    view ||= args[:home_view] || :open
    render! view, args
  end

  def show_with_page_layout view, args
    binding.pry
    args[:view] = view if view
    args[:main] = true
    args[:main_view] = true
    assign_modal_opts view, args unless Env.ajax?
    view_opts = @modal_opts.present? ? {} : args
    layout = params[:layout] || card.rule(:layout) || :default
    render_with_layout view, layout, view_opts
    # FIXME: using title because it's a standard view option.  hack!
  end

  def render_with_layout view, layout, args={}
    @main = false
    view ||= default_nest_view
    args[:layout] = [layout, args[:layout]].flatten.compact
    render! view, args
  end

  def with_main_opts args
    old_main_opts = @main_opts
    @main_opts = args
    yield
  ensure
    @main_opts = old_main_opts
  end

  view :layout, perms: :none, cache: :never do
    layout = process_layout voo.layout
    output [layout, (modal_slot if root?)]
  end

  def show_full_page?
    !Env.ajax?
  end

  def page_wrapper content
    <<-HTML.strip_heredoc
      <!DOCTYPE HTML>
      <html>
        <head>
          #{head_content}
        </head>
        <body>
          #{content}
        </body>
      </html>
    HTML
  end

  def head_content
    card.rule_card(:head).item_cards.map do |item|
      nest item, view: :core
    end.join "\n"
  end

  def show_layout?
    !Env.ajax? || params[:layout]
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

  def process_layout layout_name
    layout_name ||= layout_name_from_rule
    send "process_#{layout_type layout_name}_layout", layout_name.to_s
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

  def layout_card_content layout_name
    layout_card = Card.quick_fetch layout_name
    return unless layout_card&.type_id == Card::LayoutTypeID
    layout_card.content
  end

  def unknown_layout name
    scope = "mod.core.format.html_format"
    output [
               content_tag(:h1, tr(:unknown_layout, scope: scope, name: name)),
               tr(:built_in, scope: scope, built_in_layouts: built_in_layouts)
           ]
  end

  def built_in_layouts
    HTML_LAYOUTS.merge(HAML_LAYOUTS).keys.sort.join ", "
  end
end