
def assign_attributes args={}
  args = prepare_assignment_args args

  assign_with_subcards args do
    assign_with_set_modules args do
      params = prepare_assignment_params args
      super params
    end
  end
end

def assign_set_specific_attributes
  set_specific.each_pair do |name, value|
    send "#{name}=", value
  end
end

def extract_subcard_args! args
  subcards = args.delete("subcards") || args.delete(:subcards) || {}
  if (subfields = args.delete("subfields") || args.delete(:subfields))
    subfields.each_pair do |key, value|
      subcards[name.field(key)] = value
    end
  end
  args.keys.each do |key|
    subcards[key] = args.delete(key) if key =~ /^\+/
  end
  subcards = subcards.to_unsafe_h if subcards.respond_to?(:to_unsafe_h)
  subcards
end

protected

module ClassMethods
  def assign_or_newish name, attributes, fetch_opts={}
    if (known_card = Card.fetch(name, fetch_opts))
      known_card.refresh.newish attributes
      known_card
    else
      Card.new attributes.merge(name: name)
    end
  end
end

def prepare_assignment_params args
  args = args.to_unsafe_h if args.respond_to?(:to_unsafe_h)
  params = ActionController::Parameters.new(args)
  params.permit!
  params[:db_content] = standardize_content(params[:db_content]) if params[:db_content]
  params
end

def prepare_assignment_args args
  return {} unless args
  args = args.stringify_keys
  normalize_type_attributes args
  stash_set_specific_attributes args
  args
end

def assign_with_set_modules args
  set_changed = args["name"] || args["type_id"]
  return yield unless set_changed

  refresh_set_modules { yield }
end

def assign_with_subcards args
  subcard_args = extract_subcard_args! args
  yield
  # name= must come before process subcards
  return unless subcard_args.present?
  subcards.add subcard_args
end

def refresh_set_modules
  reinclude_set_modules = @set_mods_loaded
  yield
  reset_patterns
  include_set_modules if reinclude_set_modules
end

def stash_set_specific_attributes args
  @set_specific = {}
  Card.set_specific_attributes.each do |key|
    set_specific[key] = args.delete(key) if args.key?(key)
  end
end

def normalize_type_attributes args
  new_type_id = extract_type_id! args unless (args.delete("type_lookup") == :skip)
  args["type_id"] = new_type_id if new_type_id
end

def extract_type_id! args={}
  case
  when (type_id = args.delete("type_id")&.to_i)
    type_id.zero? ? nil : type_id
  when (type_code = args.delete("type_code")&.to_sym)
    type_id_from_codename type_code
  when (type_name = args.delete "type")
    type_id_from_cardname type_name
  end
end

def type_id_from_codename type_code
  type_id_or_error(type_code) { Card::Codename.id type_code }
end

def type_id_from_cardname type_name
  type_id_or_error(type_name) { Card.fetch_id type_name }
end

def type_id_or_error val
  type_id = yield
  return type_id if type_id

  errors.add :type, "#{val} is not a known type."
  nil
end

# 'set' refers to the noun not the verb
def set_specific
  @set_specific ||= {}
end
