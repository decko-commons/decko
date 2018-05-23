
format :html do
  def editor
    :text_field
  end
end

event :validate_number, :validate, on: :save do
  errors.add :content, "'#{content}' is not numeric" unless valid_number?(content)
end

def valid_number? string
  valid = true
  begin
    Kernel.Float(string)
  rescue ArgumentError, TypeError
    valid = false
  end
  valid
end
