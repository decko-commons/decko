format :html do
  view :overlay_rule, cache: :never, tags: :unknown_ok do
    return "not a rule" unless card.is_rule?
    rule_view = open_rule_body_view
    wrap_with_overlay do
      open_rule_wrap(rule_view) do
        [open_rule_setting_links,
         open_rule_body(rule_view)]
      end
    end
  end

  view :overlay_title do
      wrap_with(:div, class: "d-flex flex-column") do
        [wrap_with(:div, setting_title, class: "title bold"),
         render_overlay_rule_help]
      end
  end

  view :overlay_rule_help, tags: :unknown_ok, perms: :none, cache: :never do
    wrap_with :div, class: "help-text rule-instruction" do
      rule_based_help
    end
  end
end
