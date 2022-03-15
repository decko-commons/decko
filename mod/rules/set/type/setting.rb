format :data do
  view :core do
    cql = { left: { type: SetID },
            right: card.id,
            limit: 0 }
    Card.search(cql).compact.map { |c| nest c }
  end
end

def count
  Card.search left: { type: SetID }, right: id, limit: 0, return: :count
end

def set_classes_with_rules
  Pattern.concrete.reverse.map do |set_class|
    rules = rules_for_set_class set_class
    [set_class, rules] unless rules.empty?
  end.compact
end

def rules_for_set_class set_class
  cql = { left: { type: SetID }, right: id, sort: %w[content name], limit: 0 }
  cql[:left][(set_class.anchorless? ? :id : :right_id)] = set_class.pattern_id
  Card.search cql
end

format :html do
  def rule_link rule, text
    link_to_card rule, text, path: { view: :modal_rule },
                             slotter: true, "data-modal-class": "modal-lg"
  end

  view :core do
    haml do
      <<-'HAML'.strip_heredoc
        = _render_rule_help
        %h3 All #{card.name.tr "*", ""} rules that apply to
        - card.set_classes_with_rules.each do |klass, rules|
          %p
            %h5
              = klass.generic_label.downcase
            - if klass.anchorless?
              = nest rules.first, view: :bar, show: :full_name
            - else
              - rules.each do |rule|
                = nest rule, view: :bar
      HAML
    end
  end

  # Because +*help content renders in "template" mode when you render its content
  # directly, we render the help text in the context of the *all+<setting> card
  view :rule_help do
    nest [:all, card.name], view: :rule_help
  end

  view :one_line_content do
    render_rule_help
  end
end

format :json do
  def items_for_export
    Card.search left: { type: SetID }, right: card.id, limit: 0
  end
end
