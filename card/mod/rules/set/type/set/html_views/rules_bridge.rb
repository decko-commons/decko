format :html do
  view :bridge_rules_tab, cache: :never do
    output [rules_filter, render_rules_list]
  end

  SETTING_OPTIONS = [["Common", :common_rules], ["All", :all_rules],
                     ["Field", :field_related_rules],
                     ["Recent", :recent_rules]].freeze

  FIELD_SETTINGS = %i[default help structure].freeze

  def setting_select
    select_tag(:group, grouped_options_for_select(setting_options),
               class: "_submit-on-select form-control")
  end

  def setting_options
    [["Categories", SETTING_OPTIONS], ["Groups", Card::Setting.group_names.keys],
     ["Single rules", card.visible_setting_codenames]]
  end

  def set_select
    options = card.related_sets(true).map do |name, label|
      [label, name.to_name.url_key]
    end
    select_tag(:mark,
               options_for_select(options),
               class: "_submit-on-select form-control",
               "data-minimum-results-for-search": "Infinity")
  end

  def rules_filter
    form_tag path(mark: "", view: :rules_list, slot: { hide: :content }),
             remote: true, method: "get", role: "filter",
             "data-slot-selector": ".card-slot.rules_list-view",
             class: classy("nodblclick slotter form-inline slim-select2 m-2") do
      output [
        label_tag(:view, icon_tag("filter_list"), class: "mr-2"),
        setting_select,
        content_tag(:span, "rules that apply to set ...", class: "mx-2 small"),
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

  view :rules_list, wrap: :slot do
    group = params[:group]&.to_sym || :common
    rules_list group, setting_list(group)
  end

  # @param val setting category, setting group or single setting
  def setting_list val
    category_setting_list(val) || group_setting_list(val) || [val]
  end

  def group_setting_list group
    card.visible_settings(group).map(&:codename) if Card::Setting.groups[group]
  end

  def category_setting_list cat
    case cat
    when :all, :all_rules
      card.visible_setting_codenames.sort
    when :recent, :recent_rules
      recent_settings
    when :common, :common_rules
      card.visible_setting_codenames & COMMON_RULE_SETTINGS
    when :field_related, :field_related_rules
      field_related_settings
    end
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

  def field_related_settings
    field_settings = %i[default help structure]
    if card.type_id == PointerID
      # FIXME: isn't card always of type set???
      # FIXME: should be done with override in pointer set module
      field_settings += %i[input options options_label]
    end
    card.visible_setting_codenames & field_settings
  end

  def recent_settings
    recent_settings = Card[:recent_settings].item_cards.map(&:codename)
    recent_settings.map(&:to_sym) & card.visible_setting_codenames
  end

  view :field_related_rules_list do
    rules_list :field_related, field_related_settings
  end
end
