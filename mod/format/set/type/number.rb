format :html do
  def input_type
    :text_field
  end
end

event :validate_number, :validate, on: :save do
  unless content.to_s.valid?
    errors.add :content,
               t(:format_not_numeric, content: content)
  end
end
