JUNK_INIT_ARGS = %w[missing skip_virtual id].freeze

module ClassMethods
  def with_normalized_new_args args={}
    args = (args || {}).stringify_keys
    JUNK_INIT_ARGS.each { |a| args.delete(a) }
    %w[type type_code].each { |k| args.delete(k) if args[k].blank? }
    args.delete("content") if args["attach"] # should not be handled here!
    yield args
  end

  def new args={}, _options={}
    with_normalized_new_args args do |normalized_args|
      super normalized_args
    end
  end
end

def initialize args={}
  args["name"] = initial_name args["name"]
  args["db_content"] = args.delete "content" if args["content"]
  @supercard = args.delete "supercard" # must come before name=

  handle_set_modules args do
    handle_type args do
      super args # ActiveRecord #initialize
    end
  end
  self
end

def handle_set_modules args
  skip_modules = args.delete "skip_modules"
  yield
  include_set_modules unless skip_modules
end

def handle_type args
  skip_type_lookup = args["skip_type_lookup"]
  yield
  self.type_id = get_type_id_from_structure if !type_id && !skip_type_lookup
end

def initial_name name
  return name if name.is_a? String
  Card::Name[name].to_s
end

def include_set_modules
  unless @set_mods_loaded
    set_modules.each do |m|
      singleton_class.send :include, m
    end
    assign_set_specific_attributes
    @set_mods_loaded = true
  end
  self
end
