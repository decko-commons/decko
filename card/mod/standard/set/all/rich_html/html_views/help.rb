format :html do
  view :help, unknown: true, cache: :never do
    help_text = voo.help || rule_based_help
    return "" unless help_text.present?

    wrap_with :div, help_text, class: classy("help-text")
  end

  view :lead do
    class_up "card-slot", "lead"
    _view_content
  end

  def rule_based_help
    return "" unless (rule_card = card.help_rule_card)

    with_nest_mode :normal do
      process_content rule_card.content, chunk_list: :references
      # render help card with current card's format
      # so current card's context is used in help card nests
    end
  end
end
