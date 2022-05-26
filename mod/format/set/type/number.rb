format :html do
  def input_type
    :text_field
  end
end

event :validate_number, :validate, on: :save do
  errors.add :content, t(:format_not_numeric, content: content) unless content.number?
end
