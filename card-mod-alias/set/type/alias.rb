include_set Abstract::Pointer
include_set Abstract::IdPointer

event :validate_alias_source, :validate do
  return if name.simple?

  errors.add :name, t(:alias_must_be_simple)
end

event :validate_alias_target, :validate do
  return if count == 1 && target_name&.simple?

  errors.add :content, t(:alias_target_must_be_simple)
end

def alias?
  true
end

def target_name
  first_name
end

def target_card
  first_card
end

format :html do
  def input_type
    :autocomplete
  end
end
