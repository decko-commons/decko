format :html do
  view :overlay_rule, cache: :never, unknown: true do
    wrap_with_overlay slot: breadcrumb_data("Rule editing", "rules") do
      current_rule_form
    end
  end

  view :modal_rule, cache: :never, unknown: true, wrap: :modal do
    current_rule_form
  end

  view :overlay_title do
    edit_rule_title
  end

  view :overlay_rule_help, unknown: true, perms: :none, cache: :never do
    # wrap_with :div, class: "help-text rule-instruction d-flex justify-content-between"
    # do

    # output [wrap_with(:div, rule_based_help), setting_link]
    # end
    popover_link([rule_based_help, setting_link].join(" "))
  end

  def setting_link
    wrap_with :div, class: "ml-auto" do
      # FIXME: hardcoded count
      link_to_card card.rule_setting_name, " (37 #{card.rule_setting_title} rules)",
                   class: "text-muted", target: "wagn_setting"
    end
  end
end
