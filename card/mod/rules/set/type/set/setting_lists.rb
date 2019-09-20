format :html do
  SETTING_OPTIONS = [["Common", :common_rules],
                     ["All", :all_rules],
                     ["Field", :field_related_rules],
                     ["Recent", :recent_rules]].freeze

  COMMON_SETTINGS = %i[create read update delete structure default guide].freeze
  FIELD_SETTINGS = %i[default help].freeze

  def setting_options
    [["Categories", SETTING_OPTIONS],
     ["Groups", Card::Setting.group_names.keys],
     ["Single rules", card.visible_setting_codenames]]
  end

  def field_settings
    %i[default help input_type content_options content_option_view]
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
      card.visible_setting_codenames & COMMON_SETTINGS
    when :field_related, :field_related_rules
      field_related_settings
    when :nest_editor_field_related
      nest_editor_field_related_settings
    end
  end

  def nest_editor_field_related_settings
    field_settings #  & card.visible_settings(nil, card.prototype_default_type_id).map(&:codename)
  end

  def field_related_settings
    field_settings # card.visible_setting_codenames &
  end

  def recent_settings
    recent_settings = Card[:recent_settings].item_cards.map(&:codename)
    recent_settings.map(&:to_sym) & card.visible_setting_codenames
  end

  view :all_rules_list do
    pill_rule_list card.visible_setting_codenames.sort
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
    pill_rule_list settings
  end

  view :common_rules_list do
    settings = card.visible_setting_codenames & COMMON_SETTINGS # "&" = set intersection
    pill_rule_list settings
  end

  view :field_related_rules_list do
    pill_rule_list  field_related_settings
  end
end
