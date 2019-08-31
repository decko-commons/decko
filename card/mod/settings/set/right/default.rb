include_set Abstract::TemplatedNests

format :html do
  view :one_line_content do
    raw = _render_raw
    "#{card.type_name} : #{raw.present? ? raw : '<em>empty</em>'}"
  end

  def quick_editor
    wrap_type_formgroup do
      type_field class: "type-field rule-type-field _submit-on-select"
    end +
      wrap_content_formgroup do
        text_field :content, class: "d0-card-content _submit-after-typing"
      end
  end

  def visible_cardtype_groups
    hash = Self::Cardtype::GROUP.slice("Text",  "Data", "Upload")
    hash["Organize"] = ["List", "Pointer", "Link list"]
    hash
  end
end

def empty_ok?
  true
end
