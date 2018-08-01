event :validate_json, :validate, on: :save, changed: :content do
  check_json_syntax if content.present?
end

def check_json_syntax
  JSON.parse content
rescue JSON::ParserError => e
  errors.add tr(:invalid_json), e.message.sub(/^\d+: /, "").to_s
end

format :html do
  def editor
    :ace_editor
  end

  def ace_mode
    :json
  end
end
