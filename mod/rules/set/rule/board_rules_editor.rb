format :html do
  view :overlay_rule, cache: :never, unknown: true do
    wrap_with_overlay slot: breadcrumb_data("Rule editing", "rules") do
      current_rule_form
    end
  end

  view :modal_rule, cache: :never, unknown: true,
                    wrap: { modal: { title: ->(format) { format.render_title } } } do
    current_rule_form
  end

  view :overlay_title do
    edit_rule_title
  end

  view :help_text, unknown: true, cache: :never do
    wrap_help_text [rule_based_help, setting_link].join(" ")
  end

  def setting_link
    wrap_with :div, class: "ms-auto" do
      link_to_card card.rule_setting_name,
                   " (#{card.rule_setting.count} #{card.rule_setting_title} rules)",
                   class: "text-muted"
    end
  end
end
