format :html do
  view :help, unknown: true, cache: :never, wrap: :slot do
    help_text = voo.help || rule_based_help
    return "" unless help_text.present?

    if (rule_card = card.help_rule_card)
      edit_link = with_nest_mode(:normal) { nest(rule_card, view: :edit_link) }
      help_text = "<span class='d-none'>#{edit_link}</span>#{help_text}"
    end
    wrap_with :div, help_text, class: classy("help-text")
  end

  view :lead do
    class_up "card-slot", "lead"
    _view_content
  end

  def raw_help_text
    card.help_rule_card&.content
  end

  def rule_based_help
    return "" unless (help_text = raw_help_text)

    with_nest_mode :normal do
      process_content help_text, chunk_list: :references
      # render help card with current card's format
      # so current card's context is used in help card nests
    end
  end
end
