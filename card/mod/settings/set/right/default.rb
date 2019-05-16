include_set Abstract::TemplatedNests

format :html do
  view :closed_content do
    raw = _render_raw
    "#{card.type_name} : #{raw.present? ? raw : '<em>empty</em>'}"
  end

  def quick_editor
    wrap_type_formgroup do
      type_field class: "type-field rule-type-field _submit-on-select"
    end
  end
end

def empty_ok?
  true
end
