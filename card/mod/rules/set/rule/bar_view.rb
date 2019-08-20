format :html do
  before :bar do
    voo.show :bar_middle
  end

  view :bar, unknown: true do
    super()
  end

  view :bar_left do
    "#{find_existing_rule_card.trunk.label}: #{super()}"
  end

  view :short_content do
    closed_rule_content find_existing_rule_card
  end
end
