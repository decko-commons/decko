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

  #view :bridge, template: :haml do
  #end

  view :bridge_main do
    wrap do
      render bridge_view
    end
  end

  view :bridge_breadcrumbs do
    "bread"
  end

  view :bridge_tabs do
    lazy_loading_tabs BRIDGE_TABS, bridge_tab
  end

  view :follow_buttons do
    "Buttons"
  end

  def bridge_view
    @bridge_view ||= bridge_param :view
  end

  def bridge_tab
    @bridge_view ||= bridge_param :tab
  end

  def default_bridge_view
    :core
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

  def bridge_link_opts
    { "data-slot-selector": ".card-slot.bridge_main-view", remote: true, class: "slotter",
    path: { view: :overlay }}
  end
end