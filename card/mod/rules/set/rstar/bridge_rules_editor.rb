format :html do
  view :overlay_rule, cache: :never, tags: :unknown_ok do
    return "not a rule" unless card.is_rule?

    wrap_with_overlay slot: breadcrumb_data("Rule editing", "rules") do
      current_rule_form
    end
  end

  def current_rule_form success_view: :overlay_rule
    current_rule_format = subformat current_rule
    current_rule_format.rule_form success_view, card
  end

  def rule_form success_view, rule_context
    @rule_context = rule_context
    edit_rule_form success_view do
      [
        hidden_tags(success: @edit_rule_success),
        render_rule_form
      ].join
    end
  end

  view :rule_form, cache: :never, tags: :unknown_ok, template: :haml do
  end

  view :overlay_title do
    [wrap_with(:h5, setting_title, class: "title font-weight-bold"),
     render_overlay_rule_help]
  end

  view :overlay_rule_help, tags: :unknown_ok, perms: :none, cache: :never do
    # wrap_with :div, class: "help-text rule-instruction d-flex justify-content-between"
    # do

    # output [wrap_with(:div, rule_based_help), setting_link]
    # end
    popover_link([rule_based_help, setting_link].join(" "))
  end

  def setting_link
    wrap_with :div, class: "ml-auto" do
      link_to_card card.rule_setting_name, " (37 #{card.rule_setting_title} rules)",
                   class: "text-muted", target: "wagn_setting"
    end
  end
end
