format :html do
  include AddHelp::HtmlFormat

  def quick_editor
    wrap_type_formgroup do
      type_field class: "type-field rule-type-field _submit-on-select"
    end
  end
end

def empty_ok?
  true
end
