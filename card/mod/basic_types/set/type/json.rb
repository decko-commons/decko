# include_set Abstract::Pointer

event :validate_json, :validate, on: :save, changed: :content do
  check_json_syntax if content.present?
end

def check_json_syntax
  parse_content
rescue JSON::ParserError => e
  errors.add tr(:invalid_json), e.message.sub(/^\d+: /, "").to_s
end

def parse_content
  JSON.parse content
end

def item_names _args={}
  parse_content.keys.map(&:to_name)
end

def item_values
  parse_content.values
end

def item_value name
  parse_content[name]
end

format :html do
  view :core do
    process_content ::CodeRay.scan(_render_raw, :json).div
  end

  def input_type
    :ace_editor
  end

  def ace_mode
    :json
  end
end
