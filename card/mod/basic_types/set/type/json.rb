event :validate_json, :validate, on: :save, changed: :content do
  check_json_syntax
end

def check_json_syntax
  JSON.parse content
rescue JSON::ParserError => e
  errors.add "invalid json", e.message.sub(/^\d+: /, "").to_s
end

format :html do
  def editor
    :ace_editor
  end

  def ace_mode
    :json
  end
end
