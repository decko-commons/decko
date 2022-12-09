format :html do
  before :open do
    voo.hide :template_closer
  end

  view :core, cache: :never do
    [
      content_tag(:h4, t("rules_header"), class: "mt-3"),
      filtered_rule_list(:accordion_bar_list)
    ]
  end

  view :set_label do
    wrap_with :strong, card.label, class: "set-label"
  end

  view :input do
    "Cannot currently edit Sets" # LOCALIZE
  end

  view :one_line_content, wrap: {} do
    ""
  end
end
