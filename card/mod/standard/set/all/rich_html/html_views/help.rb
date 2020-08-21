def help_rule_card
  help_card = rule_card(:help)
  help_card if help_card&.ok?(:read)
end

format :html do
  view :help, unknown: true, cache: :never, wrap: :slot do
    help = help_text
    return "" unless help.present?

    wrap_with :div, wrap_help_text(help), class: classy("help-text")
  end

  view :help_text, unknown: true, cache: :never do
    wrap_help_text help_text
  end

  def wrap_help_text text
    help = text
    if (rule_card = card.help_rule_card)
      edit_link = with_nest_mode(:normal) { nest(rule_card, view: :edit_link) }
      help = "<span class='d-none'>#{edit_link}</span>#{text}"
    end
    help
  end

  view :lead do
    class_up "card-slot", "lead"
    _view_content
  end

  def help_text
    voo.help || rule_based_help
  end

  def raw_help_text
    card.try(:raw_help_text) || card.help_rule_card&.content
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
