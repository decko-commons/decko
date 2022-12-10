format :html do
  view :engage_tab, wrap: { div: { class: "m-3 mt-4 _engage-tab" } }, cache: :never do
    [render_follow_section, discussion_section].compact
  end

  view :history_tab, wrap: :slot do
    class_up "d0-card-body",  "history-slot"
    voo.hide :act_legend
    acts_bridge_layout card.history_acts
  end

  view :related_tab do
    bridge_pill_sections "Related" do
      %w[name content type].map do |section_name|
        ["by #{section_name}", send("related_by_#{section_name}_items")]
      end
    end
  end

  view :rules_tab, unknown: true do
    set_list_type = :related
    class_up "card-slot", "flex-column"
    set_cards = card.set_list set_list_type
    wrap do
      [
        set_select(set_list_type),
       # set_alert(set_list_type)
      ]
    end
  end

  view :follow_section, wrap: :slot, cache: :never do
    follow_section
  end

  view :guide_tab, unknown: true do
    render_guide
  end

  def discussion_section
    return unless show_discussion?

    field_nest(:discussion, view: :titled, title: "Discussion", show: :comment_box,
                            hide: [:menu])
  end
end
