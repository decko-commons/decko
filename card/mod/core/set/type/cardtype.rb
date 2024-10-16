basket[:non_createable_types] = [:mod]

def cards_of_type_exist?
  !new_card? && Card.where(trash: false, type_id: id).exist?
end

def create_ok?
  Card.new(type_id: id).ok? :create
end

def was_cardtype?
  type_id_before_act == Card::CardtypeID
end

event :check_for_cards_of_type, after: :validate_delete do
  errors.add :cardtype, t(:core_cards_exist, cardname: name) if cards_of_type_exist?
end

event :check_for_cards_of_type_when_type_changed,
      :validate, changing: :type, when: :was_cardtype? do
  if cards_of_type_exist?
    errors.add :cardtype, t(:core_error_cant_alter, name: name_before_act)
  end
end

event :validate_cardtype_name, :validate, on: :save, changed: :name do
  if %r{[<>/]}.match?(name)
    errors.add :name, t(:core_error_invalid_character_in_cardtype, banned: "<, >, /")
  end
end
