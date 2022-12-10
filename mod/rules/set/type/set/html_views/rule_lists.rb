format :html do
  setting_list_view_options = { cache: :never,
                                wrap: { slot: { class: "_setting-list" } } }

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
    voo.items[:view] ||= setting_list v
    pill_setting_list true
  end

  view :accordion_rule_list, setting_list_view_options do
    category_accordion(:rule_bridge_link) do |list|
      bridge_pills list
    end
  end

  view :accordion_bar_list do
    category_accordion(:bar) do |list|
      list_tag class: "nav flex-column", items: { class: "nav-item" } do
        list
      end
    end
  end

  def category_accordion view
    class_up "accordion-item", "_setting-group"
    wrap_with :div, class: "_setting-list" do
      accordion do
        Card::Setting.groups.keys.map do |group_key|
          list =
            card.group_settings(group_key).map do |setting|
              setting_list_item setting, view
            end
          body = yield list
          count_badge = "<span class=\"_count badge bg-secondary ms-3\">#{list.size}</span>"
          accordion_item "#{group_key} #{count_badge}", body: body
        end
      end
    end
  end

  view :overlay_rule_list_link, cache: :never do
    opts = bridge_link_opts(class: "edit-rule-link btn btn-primary")
    # opts[:path].delete(:layout)

    wrap_with :div do
      link_to_view(:core, "Show existing rules", opts)
    end
  end

  def quick_edit_setting_list
    classes = "nav nav-pills flex-column bridge-pills _setting-list _setting-group"
    list_tag class: classes do
      category_setting_list_items :field, :quick_edit
    end
  end

  def pill_setting_list open_rule_in_modal=false
    item_view = open_rule_in_modal ? :rule_nest_editor_link : :rule_bridge_link
    bridge_pills all_setting_list_items(item_view)
  end

  def bar_setting_list
    all_setting_list_items(:bar, hide: :full_name).join("\n").html_safe
  end

  view :pill_setting_list, cache: :never, wrap: { slot: { class: "_setting-list" } } do
    pill_setting_list
  end

  def category_setting_list_items category, item_view, options={}
    card.category_settings(category).map do |setting|
      setting_list_item setting, item_view, options
    end
  end

  def all_setting_list_items item_view, options={}
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
