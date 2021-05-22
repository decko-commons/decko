format :html do
  def input_type
    :text_field
  end
end

event :validate_number, :validate, on: :save do
  unless valid_number?(content)
    errors.add :content,
               t(:format_not_numeric, content: content)
  end
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
