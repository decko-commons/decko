include_set Abstract::ProsemirrorEditor
include_set Abstract::TinymceEditor
include_set Abstract::AceEditor

Self::InputOptions.add_to_basket :options, "text area"
Self::InputOptions.add_to_basket :options, "text field"

format :html do
  def editor
    (c = card.rule(:input)) && c.gsub(/[\[\]]/, "").tr(" ", "_")
  end

  def editor_method editor_type
    "#{editor_type}_input"
  end

  def editor_defined_by_card
    return unless (editor_card = Card[editor])
    nest editor_card, view: :core
  end

  view :editor do
    try(editor_method(editor)) ||
      editor_defined_by_card ||
      send(editor_method(default_editor))
  end

  def default_editor
    :rich_text
  end

  # overridden by mods that provide rich text editors
  def rich_text_input
    default_editor = Cardio.config.rich_text_editor || :tinymce
    send "#{default_editor}_editor_input"
  end

  def text_area_input
    text_area :content, rows: 5, class: "d0-card-content",
                        "data-card-type-code" => card.type_code
  end

  def text_field_input
    text_field :content, class: "d0-card-content"
  end
end
