require_dependency "json"

def self.member_names
  @@member_names ||= begin
    Card.search(
      { type_id: SettingID, return: "key" },
      "all setting cards"
    ).each_with_object({}) do |card_key, hash|
      hash[card_key] = true
    end
  end
end

format :data do
  view :core do
    wql = { left: { type: Card::SetID },
            right: card.id,
            limit: 0 }
    Card.search(wql).compact.map { |c| nest c }
  end
end

def set_classes_with_rules
  Card.set_patterns.reverse.map do |set_class|
    wql = { left: { type: Card::SetID },
            right: id,
            sort: %w[content name],
            limit: 0 }
    wql[:left][(set_class.anchorless? ? :id : :right_id)] = set_class.pattern_id

    rules = Card.search wql
    [set_class, rules] unless rules.empty?
  end.compact
end

format :html do
  def duplicate_check rules
    previous_content = nil
    rules.each do |rule|
      current_content = rule.db_content.strip
      duplicate = previous_content == current_content
      changeover = previous_content && !duplicate
      previous_content = current_content
      yield rule, duplicate, changeover
    end
  end

  def rule_link rule, text
    link_to_card rule, text, path: { view: :modal_rule },
                             slotter: true, "data-modal-class": "modal-lg"
  end

  view :core do
    haml do
      <<-'HAML'.strip_heredoc
        = _render_rule_help
        %table.table.setting-rules
          %thead.thead-dark
            %th Set
            %th Rule
          - card.set_classes_with_rules.each do |klass, rules|
            %thead.thead-light
              %tr.klass-row
                %th{class: ['setting-klass', "anchorless-#{klass.anchorless?}"]}
                  = klass.anchorless? ? rule_link(rules.first, klass.pattern) : klass.pattern
                %th.rule-content-container
                  %span.closed-content.content
                    - if klass.anchorless?
                      = subformat(rules.first)._render_closed_content
            - if !klass.anchorless?
              %tbody
                - duplicate_check(rules) do |rule, duplicate, changeover|
                  %tr{class: ('rule-changeover' if changeover)}
                    %td.rule-anchor
                      = rule_link rule, rule.name.trunk_name.trunk_name
                    - if duplicate
                      %td
                    - else
                      %td.rule-content-container
                        %span.closed-content.content
                          = subformat(rule)._render_closed_content
      HAML
    end
  end

  # Because +*help content renders in "template" mode when you render its content
  # directly, we render the help text in the context of the *all+<setting> card
  view :rule_help do
    nest [:all, card.name], view: :rule_help
  end

  view :closed_content do
    render_rule_help
  end
end

format :json do
  def items_for_export
    Card.search left: { type: Card::SetID }, right: card.id, limit: 0
  end
end
