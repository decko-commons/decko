format :html do
  RELATED_ITEMS =
    {
      "by name" => [["children", :children],
                    ["mates", :mates]],
      # FIXME: optimize,
      "by content" => [["links out", :links_to],
                       ["links in", :linked_to_by],
                       ["nests", :nests],
                       ["nested by", :nested_by],
                       ["references out", :refers_to],
                       ["references in",  :referred_to_by]]
      # ["by edit", [["creator", :creator],
      #              ["editors", :editors],
      #              ["last edited", :last_edited]]]
    }.freeze

  BRIDGE_PILL_CLASSES =
    "nav nav-pills _auto-single-select bridge-pills flex-column".freeze

  view :engage_tab, wrap: { div: { class: "m-3 mt-4 _engage-tab" } }, cache: :never do
    [render_follow_section, discussion_section].compact
  end

  view :history_tab, wrap: :slot do
    class_up "d0-card-body",  "history-slot"
    voo.hide :act_legend
    acts_bridge_layout card.history_acts
  end

  view :related_tab do
    wrap_with :ul, class: BRIDGE_PILL_CLASSES do
      %w[name content type].map { |n| related_section(n) }
    end
  end

  view :rules_tab, unknown: true do
    class_up "card-slot", "flex-column"
    wrap do
      nest current_set_card, view: :bridge_rules_tab
    end
  end

  view :account_tab do
    bridge_pills bridge_pill_items(account_items, "Account")
  end

  view :follow_section, wrap: :slot, cache: :never do
    follow_section
  end

  view :guide_tab, unknown: true do
    render_guide
  end

  def related_by_name_items
    pills = []
    if card.name.junction?
      pills += card.name.ancestors.map { |a| [a, a, { mark: :absolute }] }
    end
    pills += RELATED_ITEMS["by name"]
    pills
  end

  def related_by_content_items
    RELATED_ITEMS["by content"]
  end

  def related_by_type_items
    [["#{card.type} cards", [card.type, :type, :by_name], mark: :absolute]]
  end

  def related_section category
    items = send("related_by_#{category}_items")
    wrap_with(:h6, "by #{category}", class: "ml-1 mt-3") +
      wrap_each_with(:li, class: "nav-item") do
        bridge_pill_items(items, "Related")
      end.html_safe
  end

  def discussion_section
    return unless show_discussion?

    field_nest(:discussion, view: :titled, title: "Discussion", show: :comment_box,
                            hide: [:menu])
  end

  def account_items
    %i[account roles created edited follow].map do |item|
      if item == :account
        [tr(:details), item, { view: :edit, hide: %i[edit_name_row edit_type_row] }]
      else
        [tr(item), item]
      end
    end
  end

  def bridge_pills items
    list_tag class: BRIDGE_PILL_CLASSES, items: { class: "nav-item" } do
      items
    end
  end

  def bridge_pill_items data, breadcrumb
    data.map do |text, field, extra_opts|
      opts = bridge_pill_item_opts breadcrumb, extra_opts, text
      mark = opts.delete(:mark) == :absolute ? field : [card, field]
      link_to_card mark, text, opts
    end
  end

  def bridge_pill_item_opts breadcrumb, extra_opts, text
    opts = bridge_link_opts.merge("data-toggle": "pill")
    opts.merge! breadcrumb_data(breadcrumb)

    if extra_opts
      classes = extra_opts.delete :class
      add_class opts, classes if classes
      opts.deep_merge! extra_opts
    end
    opts["data-cy"] = "#{text.to_name.key}-pill"
    add_class opts, "nav-link"
    opts
  end
end
