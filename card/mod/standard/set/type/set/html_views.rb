
format :html do
  COMMON_RULE_SETTINGS =
    %i[create read update delete structure default style].freeze

  view :core, cache: :never do
    voo.show :set_label, :rule_navbar
    voo.hide :set_navbar
    rule_view = params[:rule_view] || :common_rules
    _render rule_view
  end

  def with_label_and_navbars selected_view
    @selected_rule_navbar_view = selected_view
    wrap do
      [
        _render_set_label,
        _render_rule_navbar,
        _render_set_navbar,
        yield
      ]
    end
  end

  view :all_rules do
    with_label_and_navbars :all_rules do
      rules_table card.visible_setting_codenames.sort
    end
  end

  view :grouped_rules do
    with_label_and_navbars :grouped_rules do
      wrap_with :div, class: "panel-group", id: "accordion",
                      role: "tablist", "aria-multiselectable": "true" do
        Card::Setting.groups.keys.map do |group_key|
          _render group_key
        end
      end
    end
  end

  view :recent_rules do
    with_label_and_navbars :recent_rules do
      recent_settings = Card[:recent_settings].item_cards.map(&:codename)
      settings = recent_settings.map(&:to_sym) & card.visible_setting_codenames
      rules_table settings
    end
  end

  view :common_rules do
    with_label_and_navbars :common_rules do
      settings = card.visible_setting_codenames & COMMON_RULE_SETTINGS
      # "&" = set intersection
      rules_table settings
    end
  end

  view :field_related_rules do
    with_label_and_navbars :field_related_rules do
      field_settings = %i[default help structure]
      if card.type_id == PointerID
        # FIXME: should be done with override in pointer set module
        field_settings += %i[input options options_label]
      end
      settings = card.visible_setting_codenames & field_settings
      rules_table settings
    end
  end

  view :set_label do
    wrap_with :h3, card.label, class: "set-label"
  end

  Card::Setting.groups.each_key do |group_key|
    view group_key.to_sym do
      next unless card.visible_settings(group_key).present?
      haml :group_panel, group_key: group_key
    end
  end

  def rules_table settings
    haml :rules_table, settings: settings
  end

  view :editor do
    "Cannot currently edit Sets" # ENGLISH
  end

  view :closed_content do
    ""
  end

  view :set_navbar do
    id = "set-navbar-#{card.name.safe_key}-#{voo.home_view}"
    related_sets = card.related_sets(true)
    return "" if related_sets.size <= 1
    navbar id, brand: "Set", toggle_align: :right,
               class: "slotter toolbar navbar-expand-md",
               navbar_type: "dark",
               collapsed_content: close_link("float-right d-sm-none") do
      set_navbar_content related_sets
    end
  end

  def li_pill content, active
    "<li role='presentation' class='nav-item #{'active' if active}'>#{content}</li>"
  end

  view :rule_navbar do
    navbar "rule-navbar-#{card.name.safe_key}-#{voo.home_view}",
           brand: "Rules", toggle_align: :right,
           class: "slotter toolbar navbar-expand-md bg-dark", navbar_type: "dark",
           collapsed_content: close_link("float-right d-sm-none") do
      rule_navbar_content
    end
  end

  def rule_navbar_pills
    pills = [["common",   :common_rules],
             ["by group", :grouped_rules],
             ["by name",  :all_rules]]
    pills.unshift ["field", :field_related_rules] if card.junction?
    pills.push ["recent", :recent_rules] if recently_edited_settings?
    pills
  end

  def rule_navbar_content
    wrap_with :ul, class: "nav navbar-nav nav-pills" do
      rule_navbar_pills.map do |label, symbol|
        view_link_pill label, symbol
      end
    end
  end

  def set_navbar_content related_sets
    wrap_with :ul, class: "nav navbar-nav nav-pills" do
      related_sets.map do |name, label|
        slot_opts = { subheader: title_in_context(name),
                      subframe: true,
                      hide: "header set_label rule_navbar",
                      show: "subheader set_navbar" }
        link = link_to_card name, label, remote: true,
                                         path: { view: @slot_view,
                                                 slot: slot_opts },
                                         class: "nav-link"
        li_pill link, name == card.name
      end
    end
  end

  def view_link_pill name, view
    selected_view = @selected_rule_navbar_view || @slot_view || voo.home_view
    link = link_to_view view, name, class: "nav-link slotter", role: "pill",
                                    path: { slot: { show: :rule_navbar } }
    li_pill link, selected_view == view
  end
end
