include_set Abstract::Pointer
include_set Abstract::IdPointer

event :validate_alias_source, :validate, on: :save do
  errors.add :name, t(:alias_must_be_simple) if name.compound?
  errors.add :type, t(:alias_cards_no_children) if child_ids.present?
end

event :validate_alias_target, :validate, on: :save do
  return if count == 1 && target_name&.simple?

  errors.add :content, t(:alias_target_must_be_simple)
end

def alias?
  true
end

# @return [Card::Name] name to which card's name is aliased
def target_name
  first_name
end

# @return [Card] card to which card is aliased
def target_card
  first_card
end

format :html do
  def input_type
    :autocomplete
  end
end
