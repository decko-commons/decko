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
    class_up "card-slot", "flex-column"
    wrap do
      nest current_set_card, view: :bridge_rules_tab
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
