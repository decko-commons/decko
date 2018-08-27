
# nest({ wikipedia: { editable: false, type: :phrase, default: "dfds" }}, :about, :address)

format :html do
  # TODO: use CodeFile cards for these
  # builtin layouts allow for rescue / testing
  HTML_LAYOUTS = Mod::Loader.load_layouts(:html).merge "none" => "{{_main}}"
  HAML_LAYOUTS = Mod::Loader.load_layouts(:haml)

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

  # def process_layout layout_name
  #   layout_name ||= layout_name_from_rule
  #   send "process_#{layout_type layout_name}_layout", layout_name.to_s
  # end

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
