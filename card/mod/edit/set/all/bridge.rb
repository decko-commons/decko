format :html do
  BRIDGE_TABS = { account_tab: "Account",
                  engage_tab: "Engage",
                  history_tab: "History",
                  related_tab: "Related",
                  rules_tab: "Rules" }.freeze

  wrapper :bridge do
    class_up "modal-dialog", "no-gaps"
    voo.hide! :modal_footer
    wrap_with_modal size: :full, title: bridge_breadcrumbs do
      haml :bridge
    end
  end

  def bridge_tabs
    wrap do
      lazy_loading_tabs visible_bridge_tabs, bridge_tab, _render(bridge_tab)
    end
  end

  def bridge_tab
    @bridge_tab ||= bridge_param :tab
  end

  def bridge_param key
    params.dig(:bridge, key)&.to_sym || try("default_bridge_#{key}")
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

  def bridge_link_opts opts={}
    opts[:"data-slot-selector"] = bridge_slot_selector
    opts[:remote] = true
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
    show_account_tab? ? :account_tab : :engage_tab
  end

  def breadcrumb_data title, html_class=nil
    html_class ||= title.underscore
    { "data-breadcrumb": title, "data-breadcrumb-class": html_class }
  end
end
