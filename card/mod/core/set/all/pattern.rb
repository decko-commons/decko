def patterns?
  defined? @patterns
end

def all_patterns
  @all_patterns ||= set_patterns.map { |sub| sub.new self }.compact
end

# new cards do not
def patterns
  @patterns ||= (new_card? ? all_patterns[1..-1] : all_patterns)
end

def reset_patterns
  # Rails.logger.info "resetting patterns: #{name}"
  @patterns = @all_patterns = nil
  @template = @virtual = nil
  @set_mods_loaded = @set_modules = @set_names = @rule_set_keys = nil
  @junction_only = nil # only applies to set cards
  true
end

def reset_patterns_if_rule _saving=false
  return unless real? && is_rule? && (set = left)
  set.reset_patterns
  set.include_set_modules
  set
end

def safe_set_keys
  patterns.map(&:safe_key).reverse * " "
end

def set_modules
  @set_modules ||= all_patterns[0..-2].reverse.map(&:module_list).flatten.compact
end

def set_format_modules klass
  @set_format_modules ||= {}
  @set_format_modules[klass] =
    all_patterns[0..-2].reverse.map do |pattern|
      pattern.format_module_list klass
    end.flatten.compact
end

def set_names
  @set_names = patterns.map(&:to_s) if @set_names.nil?
  @set_names
end

def in_set? set_module
  patterns.map(&:module_key).include? set_module.shortname
end

def rule_set_keys
  @rule_set_keys ||= patterns.map(&:rule_set_key).compact
end

def include_module? set
  singleton_class&.include? set
end
