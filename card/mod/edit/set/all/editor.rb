include_set Abstract::ProsemirrorEditor
include_set Abstract::TinymceEditor
include_set Abstract::AceEditor

Self::InputOptions.add_to_basket :options, "text area"
Self::InputOptions.add_to_basket :options, "text field"

format :html do
  def input_type
    (c = card.rule(:input_type)) && c.gsub(/[\[\]]/, "").tr(" ", "_")
  end

  def input_method input_type
    "#{input_type}_input"
  end

  def input_defined_by_card
    return unless (input_card = Card[input_type])

    nest input_card, view: :core
  end

  view :input, unknown: true do
    try(input_method(input_type)) ||
      input_defined_by_card ||
      send(input_method(default_input_type))
  end

  def default_input_type
    :rich_text
  end

  # overridden by mods that provide rich text editors
  def rich_text_input
    send "#{Cardio.config.rich_text_editor || :tinymce}_editor_input"
  end

  def text_area_input
    text_area :content, rows: 5, class: "d0-card-content",
                        "data-card-type-code" => card.type_code
  end

  def text_field_input
    text_field :content, class: classy("d0-card-content")
  end
end
