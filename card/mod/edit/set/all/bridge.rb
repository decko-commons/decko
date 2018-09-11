format :html do
  BRIDGE_TABS = { account_tab: "Account",
                  engage_tab: "Engage",
                  history_tab: "History",
                  related_tab: "Related",
                  rules_tab: "Rules" }.freeze

  RELATED_ITEMS = [["children",       :baby_formula, :children],
                   # ["mates",          "bed",          "*mates"],
                   # FIXME: optimize and restore
                   ["references out", :log_out,      :refers_to],
                   ["references in",  :log_in,       :referred_to_by]].freeze

  wrapper :bridge do
    class_up "modal-dialog", "no-gaps"
    voo.hide! :modal_footer
    wrap_with_modal size: :full, title: bridge_breadcrumbs do
      haml :bridge
    end
  end

  def bridge_tabs
    lazy_loading_tabs visible_bridge_tabs, bridge_tab, _render(bridge_tab)
  end

  view :engage_tab, wrap: { div: { class: "m-3 mt-4" } } do
    [render_follow_section, discussion_section].compact
  end

  view :history_tab do
    class_up "d0-card-body",  "history-slot"
    voo.hide :act_legend
    acts_bridge_layout card.history_acts
  end

  view :related_tab do
    links = RELATED_ITEMS.map do |text, _icon, field|
      opts = bridge_link_opts.merge("data-toggle": "pill")
      add_class opts, "nav-link"
      opts.merge! breadcrumb_data("Related")
      link_to_card [card, field], text,  opts
    end
    bridge_pills links
  end

  view :rules_tab do
    class_up "card-slot", "flex-column", true
    wrap do
      nest current_set_card, view: :bridge_rules_tab
    end
  end

  view :account_tab do

  end

  view :follow_section, wrap: :slot do
    follow_section
  end

  def bridge_breadcrumbs
    <<-HTML.strip_heredoc
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb _bridge-breadcrumb">
        <li class="breadcrumb-item">#{card.name}</li>
        <li class="breadcrumb-item active">Edit</li>
      </ol>
    </nav>
    HTML
  end

  def bridge_tab
    @bridge_tab ||= bridge_param :tab
  end

  def bridge_param key
    params.dig(:bridge, key)&.to_sym || try("default_bridge_#{key}")
  end

  def visible_bridge_tabs
    BRIDGE_TABS.select do |key, title|
      send "show_#{key}?"
    end
  end

  def bridge_pills items
    list_tag class: "nav nav-pills bridge-pills flex-column", items: { class: "nav-item" } do
      items
    end
  end

  def bridge_link_opts opts={}
    opts.merge! "data-slot-selector": bridge_slot_selector, remote: true
    add_class opts, "slotter"
    opts.bury :path, :layout, :overlay
    opts[:path][:view] ||= :content
    opts
  end

  def bridge_slot_selector
    ".bridge-main > .card-slot, "\
    ".bridge-main > .overlay-container > .card-slot._bottomlay-slot"
  end

  def default_bridge_tab
    :engage_tab
  end

  def show_account_tab?
    return unless card.real?
    card.account && card.ok?(:update)
  end

  def show_engage_tab?
    return unless card.real?
    show_follow? || show_discussion?
  end

  def show_history_tab?
    card.real?
  end

  def show_related_tab?
    card.real?
  end

  def show_rules_tab?
    true
  end

  def show_discussion?
    d_card = discussion_card
    return unless d_card
    permission_task = d_card.new_card? ? :comment : :read
    d_card.ok? permission_task
  end

  def discussion_card?
    card.junction? && card.name.tag_name.key == :discussion.cardname.key
  end

  def discussion_section
    return unless show_discussion?
    field_nest(:discussion, view: :titled, title: "Discussion", show: :comment_box,
                            hide: [:menu])
  end

  def discussion_card
    return if card.new_card? || discussion_card?
    card.fetch trait: :discussion, skip_modules: true, new: {}
  end

  def follow_section
    return unless show_follow?
    wrap_with :div, class: "mb-3" do
      [follow_button, followers_bridge_link]
    end
  end

  def follow_button
    wrap_with :div, class: "btn-group btn-group-sm" do
      [follow_bridge_link(class:"btn btn-sm btn-primary"),
       link_to_card("Home", icon_tag("more_horiz"), class:"btn btn-sm btn-primary")]
    end
  end

  def breadcrumb_data title, html_class=nil
    html_class ||= title.underscore
    { "data-breadcrumb": title, "data-breadcrumb-class": html_class}
  end
end
