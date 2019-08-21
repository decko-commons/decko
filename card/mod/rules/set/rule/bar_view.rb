format :html do
  before :bar do
    voo.show :bar_middle
  end

  view :bar, unknown: true do
    super()
  end

  view :bar_left, unknown: true do
    "#{find_existing_rule_card&.trunk&.label}: #{super()}"
  end

  view :bar_middle, unknown: true do
    super()
  end

  view :short_content, unknown: true do
    closed_rule_content find_existing_rule_card
  end
end
