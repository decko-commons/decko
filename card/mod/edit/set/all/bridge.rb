format :html do
  BRIDGE_TABS = { engage_tab: "Engage",
                  history_tab: "History",
                  related_tab: "Related",
                  rules_tab: "Rules" }.freeze

  RELATED_ITEMS = [["children",       :baby_formula, :children],
                   # ["mates",          "bed",          "*mates"],
                   # FIXME: optimize and restore
                   ["references out", :log_out,      :refers_to],
                   ["references in",  :log_in,       :referred_to_by]].freeze

  def bridge_param key
    params.dig(:bridge, key)&.to_sym || try("default_bridge_#{key}")
  end

  view :bridge_breadcrumbs do
    <<-HTML
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb _bridge-breadcrumb">
        <li class="breadcrumb-item">#{card.name}</li>
        <li class="breadcrumb-item active">Edit</li>
      </ol>
    </nav>
    HTML
  end

  view :bridge_tabs do
    lazy_loading_tabs BRIDGE_TABS, bridge_tab, _render(bridge_tab)
  end

  def bridge_tab
    @bridge_tab ||= bridge_param :tab
  end

  def default_bridge_tab
    :discussion_tab
  end

  view :follow_section, wrap: :slot do
    follow_section
  end

  view :history_tab do
    class_up "d0-card-body",  "history-slot"
    voo.hide :act_legend
    acts_bridge_layout card.history_acts
  end

  view :rules_tab do
    class_up "card-slot", "flex-column", true
    wrap do
      nest current_set_card.name, view: :bridge_rules_tab
    end
  end

  view :enagage_tab, wrap: { div: { class: "m-3 mt-4" } } do
    [follow_section, discussion_section]
  end

  def follow_section
    follow = wrap_with :div, class: "btn-group btn-group-sm" do
      [follow_bridge_link(class:"btn btn-sm btn-primary"), link_to_card("Home", icon_tag("more_horiz"), class:"btn btn-sm btn-primary")]
    end
    wrap_with :div, class: "mb-3" do
      [follow, followers_bridge_link]
    end
  end

  def discussion_section
    field_nest(:discussion, view: :titled, title: "Discussion", show: :comment_box, hide: [:menu])
  end

  view :related_tab do
    links = RELATED_ITEMS.map do |text, _icon, field|
      opts = bridge_link_opts.merge("data-toggle": "pill")
      add_class opts, "nav-link"
      link_to_card [card, field], text,  opts
    end
    bridge_pills links
  end

  def bridge_pills items
    list_tag class: "nav nav-pills bridge-pills flex-column", items: { class: "nav-item" } do
      items
    end
  end

  def bridge_link_opts opts={}
    opts.merge! "data-slot-selector": bridge_slot_selector,
                remote: true
    add_class opts, "slotter"
    opts.bury :path, :layout, :overlay
    opts[:path][:view] ||= :content
    opts
  end

  def bridge_slot_selector
    ".bridge-main > .card-slot, "\
    ".bridge-main > .overlay-container > .card-slot._bottomlay-slot"
  end

  wrapper :bridge do
    class_up "modal-dialog", "no-gaps"
    voo.hide! :modal_footer
    wrap_with_modal size: :full, title: _render_bridge_breadcrumbs do
      haml :bridge
    end
  end

  def show_discuss_tab?
    discussion_card = bridge_discussion_card
    return unless discussion_card
    permission_task = discussion_card.new_card? ? :comment : :read
    discussion_card.ok? permission_task
  end

  def bridge_discussion_card
    return if card.new_card?
    return if discussion_card?
    card.fetch trait: :discussion, skip_modules: true, new: {}
  end

  def discussion_card?
    card.junction? && card.name.tag_name.key == :discussion.cardname.key
  end
end
