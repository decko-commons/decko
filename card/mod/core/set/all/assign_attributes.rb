include Card::Subcards::Args

def assign_attributes args={}
  args = prepare_assignment_args args

  assign_with_subcards args do
    assign_with_set_modules args do
      super prepare_assignment_params(args)
    end
  end
end

def assign_set_specific_attributes
  set_specific.each_pair do |name, value|
    send "#{name}=", value
  end
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
  @set_specific = {}
  return {} unless args

  args = args.symbolize_keys
  normalize_type_attributes args
  stash_set_specific_attributes args
  args
end

def assign_with_set_modules args, &block
  return yield unless args[:name] || args[:type_id]

  refresh_set_modules(&block)
end

def assign_with_subcards args
  subcard_args = extract_subcard_args! args
  yield
  subcards.add subcard_args if subcard_args.present?
end

def refresh_set_modules
  reinclude_set_modules = @set_mods_loaded
  yield
  reset_patterns
  include_set_modules if reinclude_set_modules
end

def stash_set_specific_attributes args
  Card.set_specific_attributes.each do |key|
    set_specific[key] = args.delete(key) if args.key?(key)
  end
end

# 'set' refers to the noun not the verb
def set_specific
  @set_specific ||= {}
end
