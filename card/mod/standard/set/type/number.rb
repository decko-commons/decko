
format :html do
  def editor
    :text_field
  end
end

event :validate_number, :validate, on: :save do
  errors.add :content, tr(:not_numeric, content: content) unless valid_number?(content)
end

def valid_number? string
  return true if string.empty?

  valid = true
  begin
    Kernel.Float(string)
  rescue ArgumentError, TypeError
    valid = false
  end
  valid
end
