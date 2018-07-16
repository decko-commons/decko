format :html do
  BRIDGE_TABS = { discussion_tab: "Discussion",
                  rules: "Rules",
                  history_tab: "History",
                  related_tab: "Related" }.freeze

  RELATED_ITEMS = [["children",       :baby_formula, :children],
                   # ["mates",          "bed",          "*mates"],
                   # FIXME: optimize and restore
                   ["references out", :log_out,      :refers_to],
                   ["references in",  :log_in,       :referred_to_by]].freeze

  def bridge_param key
    params.dig(:bridge, key) || try("default_bridge_#{key}")
  end

  view :bridge_breadcrumbs do
    "breadcrumbs"
  end

  view :bridge_tabs do
    lazy_loading_tabs BRIDGE_TABS, bridge_tab
  end

  def bridge_tab
    @bridge_tab ||= bridge_param :tab
  end

  def default_bridge_tab
    :discussion_tab
  end

  view :follow_buttons do
    follow_bridge_link class: "btn btn-sm btn-primary"
  end

  view :history_tab do
  end

  view :discussion_tab do
    field_nest :discussion, view: :titled, show: :comment_box, hide: :title
  end

  view :related_tab do
    links = RELATED_ITEMS.map do |text, _icon, field|
      link_to_card [card, field], text, bridge_link_opts
    end
    list_group links
  end

  def bridge_link_opts opts={}
    opts.merge! "data-slot-selector": bridge_slot_selector,
                remote: true, class: "slotter"
    opts.bury :path, :layout, :overlay
    opts[:path][:view] ||= :open_content
    opts
  end


  def bridge_slot_selector
    ".bridge-main > #main > .card-slot, "\
    ".bridge-main > #main > .overlay-container > .card-slot._bottomlay-slot"
  end
end
