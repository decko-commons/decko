def guide_card
  guide_card = rule_card(:guide)
  return unless guide_card

  guide_card = guide_card.item_cards.first if guide_card.type_id == Card::PointerID
  guide_card if guide_card.ok?(:read)
end

format :html do
  view :guide, unknown: true, cache: :never, wrap: :slot do
    guide
  end

  def guide
    guide_text = rule_based_guide
    return "" unless guide_text.present?

    if (rule_card = card.help_rule_card)
      edit_link = with_nest_mode(:normal) { nest(rule_card, view: :edit_link) }
      guide_text = "<span class='d-none'>#{edit_link}</span>#{guide_text}"
    end
    wrap_with :div, guide_text, class: classy("guide-text")
  end

  def alert_guide
    guide_text = guide
    return "" unless guide_text.present?

    alert(:secondary, true) { guide_text }
  end

  def raw_guide_text
    false
  end

  def rule_based_guide
    if raw_guide_text
      with_nest_mode :normal do
        process_content raw_guide_text, chunk_list: :references
        # render guide text with current card's format
        # so current card's context is used in guide card nests
      end
    elsif  card.guide_card
      with_nest_mode :normal do
        nest card.guide_card, view: :core
      end
    else
      ""
    end
  end
end
