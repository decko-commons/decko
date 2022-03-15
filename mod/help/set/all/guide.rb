def guide_card
  @guide_card ||= determine_guide_card
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
    return guide_text unless guide_card.ok?(:update)

    edit_link = with_nest_mode(:normal) { nest(guide_card, view: :edit_link) }
    "<span class='d-none'>#{edit_link}</span>#{guide_text}"
  end

  def guide_text
    return "" unless guide_card

    with_nest_mode :normal do
      nest guide_card, view: :core
    end
  end

  delegate :guide_card, to: :card
end

private

def determine_guide_card
  guide_card = rule_card :guide
  return unless guide_card

  guide_card = guide_card.first_card if guide_card.type_id == PointerID
  guide_card if guide_card.ok?(:read)
end
