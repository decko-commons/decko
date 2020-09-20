format :html do
  BRIDGE_TABS = { "Account" => :account_tab,
                  "Guide"   => :guide_tab,
                  "Engage"  => :engage_tab,
                  "History" => :history_tab,
                  "Related" => :related_tab,
                  "Rules"   => :rules_tab }.freeze

  wrapper :bridge do
    class_up "modal-dialog", "no-gaps"
    voo.hide! :modal_footer
    wrap_with_modal size: :full, title: bridge_breadcrumbs do
      haml :bridge
    end
  end

  def bridge_tabs
    wrap do
      tabs(visible_bridge_tabs, bridge_tab, load: :lazy) { _render bridge_tab }
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
    ".bridge-main > .overlay-container > .card-slot._bottomlay-slot," \
    ".bridge-main > ._overlay-container-placeholder > .card-slot"
  end

  def default_bridge_tab
    show_guide_tab? ? :guide_tab : :engage_tab
  end

  def breadcrumb_data title, html_class=nil
    html_class ||= title.underscore
    { "data-breadcrumb": title, "data-breadcrumb-class": html_class }
  end
end
