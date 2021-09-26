def guide_card
  guide_card = rule_card(:guide)
  return unless guide_card

  guide_card = guide_card.first_card if guide_card.type_id == Card::PointerID
  guide_card if guide_card.ok?(:read)
end

format :html do
  view :guide, unknown: true, cache: :never, wrap: :slot do
    guide
  end

  def guide
    return "" unless (text = guide_text).present?

    wrap_with :div, class: classy("guide-text") do
      prepend_guide_edit_link text
    end
  end

  def alert_guide
    rendered = guide
    return "" unless rendered.present?

    alert(:secondary, true, false, class: "guide") { rendered }
  end

  private

  def prepend_guide_edit_link guide_text
    return unless (rule_card = card.help_rule_card)

    edit_link = with_nest_mode(:normal) { nest(rule_card, view: :edit_link) }
    "<span class='d-none'>#{edit_link}</span>#{guide_text}"
  end

  def raw_guide_text
    false
  end

  def guide_text
    return "" unless (raw = raw_guide_text) || (guide_card = card.guide_card)

    with_nest_mode :normal do
      if raw
        process_content raw_guide_text, chunk_list: :references
        # render guide text with current card's format
        # so current card's context is used in guide card nests
      else
        nest guide_card, view: :core
      end
    end
  end
end
