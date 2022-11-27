format :html do
  # settings by category
  view :all_rules_list do
    pill_setting_list card.visible_setting_codenames.sort
  end

  view :recent_rules_list do
    recent_settings = Card[:recent_settings].item_cards.map(&:codename)
    settings = recent_settings.map(&:to_sym) & card.visible_setting_codenames
    pill_setting_list settings
  end

  view :common_rules_list do
    settings = card.visible_setting_codenames & COMMON_SETTINGS # "&" = set intersection
    pill_setting_list settings
  end

  view :field_related_rules_list do
    pill_setting_list card.field_related_settings
  end

  # settings by group
  Card::Setting.groups.each_key do |group_key|
    view group_key.to_sym do
      next unless card.visible_settings(group_key).present?

      haml :group_panel, group_key: group_key
    end
  end

  setting_list_view_options = { cache: :never, wrap: { slot: { class: "_setting-list" } } }

  # rule can be edited in-place
  view :quick_edit_setting_list, setting_list_view_options do
    quick_edit_setting_list
  end

  # show the settings in bars
  view :bar_setting_list, setting_list_view_options do
    bar_setting_list
  end

  # a click on a setting opens the rule editor in an overlay
  view :pill_setting_list, setting_list_view_options do
    pill_setting_list
  end

  # a click on a setting opens the rule editor in a modal
  view :modal_pill_setting_list, setting_list_view_options do
    voo.items[:view] ||=
    setting_list v
    pill_setting_list true
  end

  view :accordion_rule_list, setting_list_view_options do
    wrap_with :div, class: "_setting-list" do
      accordion do
        Card::Setting.groups.keys.map do |group_key|
          accordion_item(group_key, body: pill_setting_group_list(group_key)) #list_group(views))
        end
      end
    end
  end

  def setting_list item_view, grouped=true

  end

  view :overlay_rule_list_link, cache: :never do
    opts = bridge_link_opts(class: "edit-rule-link btn btn-primary")
    # opts[:path].delete(:layout)

    wrap_with :div do
      link_to_view(:core, "Show existing rules", opts)
    end
  end

  def quick_edit_setting_list
    list_tag class: "nav nav-pills flex-column bridge-pills _setting-list" do
      setting_list_items :quick_edit
    end
  end

  def pill_setting_list open_rule_in_modal=false
    item_view = open_rule_in_modal ? :rule_nest_editor_link : :rule_bridge_link
    bridge_pills setting_list_items(item_view)
  end

  def bar_setting_list
    setting_list_items(:bar, hide: :full_name).join("\n").html_safe
  end


  def pill_setting_group_list group_key
    list =
        card.group_setting_list(group_key).map do |setting|
          setting_list_item setting, :rule_bridge_link
        end

    bridge_pills list
  end

  view :pill_setting_list, cache: :never, wrap: { slot: { class: "_setting-list" } } do
     pill_setting_list
   end


  def  setting_list_items item_view, options = {}
    card.all_settings.map do |setting|
      setting_list_item setting, item_view, options
    end
  end

  def setting_list_item setting, view, opts={}
    return "" unless show_view? setting

    rule_card = card.fetch setting, new: {}
    nest(rule_card, opts.merge(view: view)).html_safe
  end
end
