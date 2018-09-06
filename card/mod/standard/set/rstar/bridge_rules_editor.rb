format :html do
  view :overlay_rule, cache: :never, tags: :unknown_ok do
    return "not a rule" unless card.is_rule?

    current_rule_format = subformat current_rule
    current_rule_format.rule_context = card

    wrap_with_overlay do
      current_rule_format.rule_form
    end
  end

  def rule_form
    edit_rule_form do
      [
        hidden_tags(success: @edit_rule_success),
        render_rule_form
      ].join
    end
  end

  view :rule_form, cache: :never, tags: :unknown_ok, template: :haml do
  end

  view :overlay_title do
      wrap_with(:div, class: "d-flex flex-column") do
        [wrap_with(:div, setting_title, class: "title"),
         render_overlay_rule_help]
      end
  end

  view :overlay_rule_help, tags: :unknown_ok, perms: :none, cache: :never do
    wrap_with :div, class: "help-text rule-instruction" do
      output [rule_based_help, link_to_all_rules]
    end
  end
end
