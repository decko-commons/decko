
Self::InputOptions.add_to_basket :options, "text area"
Self::InputOptions.add_to_basket :options, "text field"

format :html do
  def input_type
    voo.input_type.present? ? voo.input_type : input_type_from_rule
  end

  def input_type_from_rule
    card.rule(:input_type)&.gsub(/[\[\]]/, "")&.tr(" ", "_")
  end

  def input_method input_type
    "#{input_type}_input"
  end

  # core view of card is input
  def input_defined_by_card
    with_card input_type do |input_card|
      nest input_card, view: :core
    end
  end

  # move somewhere more accessible?
  def with_card mark
    return nil unless (card = Card[mark])

    yield card
  rescue Card::Error::CodenameNotFound
    nil
  end

  view :input, unknown: true do
    try(input_method(input_type)) ||
      input_defined_by_card ||
      send(input_method(default_input_type))
  end

  def default_input_type
    :rich_text
  end

  def rich_text_input
    send "#{Cardio.config.rich_text_editor || :text_area}_editor_input"
  end

  def text_area_input
    text_area :content, rows: 5, class: "d0-card-content",
                        "data-card-type-code" => card.type_code
  end

  def text_field_input
    text_field :content, class: classy("d0-card-content")
  end
end
