format :html do
  view :bridge_rules_tab, cache: :never do
    rules_table =
      wrap do
        render_common_rules_list hide: [:content, :set_label, :set_navbar, :rule_navbar]
      end
    output [ rules_filter, rules_table ]
  end

  SETTING_OPTIONS = [["Common", :common_rules_list], ["All", :all_rules_list],
                     ["Grouped", :grouped_rules_list], ["Field", :field_related_rules_list],
                     ["Recent", :recent_rules_list]].freeze

  FIELD_SETTINGS = %i[default help structure].freeze

  def setting_select
    select_tag(:view, options_for_select(SETTING_OPTIONS),
               class: "_submit-on-select form-control")
  end

  def set_select
    options = card.related_sets(true).map do |name, label|
      [label, name.to_name.url_key]
    end
    select_tag(:mark,
               options_for_select(options),
               class: "_submit-on-select form-control")
  end

  def rules_filter
    form_tag path(mark: "", slot: { hide: [:set_label, :rule_navbar, :set_navbar, :content] }),
             remote: true, method: "get", role: "filter",
             "data-slot-selector": "#home-rule_tab > .card-slot > .card-slot",
             class: classy("nodblclick slotter form-inline m-2") do
      output [
               label_tag(:view, "Filter", class: "mr-2"),
               setting_select,
               content_tag(:span, "rules that apply to set ...", class: "ml-2"),
               set_select
             ]
    end
  end

  def rules_list _key, items
    bridge_pills(items.map { |i| rules_list_item i })
  end

  def rules_list_item setting
    return "" unless show_view? setting
    rule_card = card.fetch trait: setting, new: {}
    nest(rule_card, view: :rule_bridge_link).html_safe
  end

  view :all_rules_list do
    rules_list :all, card.visible_setting_codenames.sort
  end

  view :grouped_rules_list do
    with_label_and_navbars :grouped_rules do
      wrap_with :div, class: "panel-group", id: "accordion",
                role: "tablist", "aria-multiselectable": "true" do
        Card::Setting.groups.keys.map do |group_key|
          _render group_key
        end
      end
    end
  end

  view :recent_rules_list do
    recent_settings = Card[:recent_settings].item_cards.map(&:codename)
    settings = recent_settings.map(&:to_sym) & card.visible_setting_codenames
    rules_list :all, settings
  end

  view :common_rules_list do
    settings = card.visible_setting_codenames & COMMON_RULE_SETTINGS
    # "&" = set intersection
    rules_list :common, settings
  end

  view :field_related_rules_list do
    field_settings = %i[default help structure]
    if card.type_id == PointerID
      # FIXME: isn't card always of type set???
      # FIXME: should be done with override in pointer set module
      field_settings += %i[input options options_label]
    end
    settings = card.visible_setting_codenames & field_settings
    rules_list :field_related, settings
  end
end
