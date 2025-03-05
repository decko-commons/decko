def to_s
  "#<#{self.class.name}[#{debug_type}]#{attributes['name']}>"
end

def inspect
  error_messages = errors.any? ? "<E*#{errors.full_messages * ', '}*>" : ""
  "#<Card##{id}[#{debug_type}](#{name})#{error_messages}{#{inspect_tags * ','}}"
end

private

def inspect_tags
  %w[trash new frozen readonly virtual set_mods_loaded].select do |tag|
    send "#{tag}?"
  end
end

def debug_type
  "#{type_code || ''}:#{type_id}"
end
