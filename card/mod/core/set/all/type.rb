module ClassMethods
  def default_type_id
    @default_type_id ||= Card.fetch_type_id %i[all default]
  end
end

event :validate_type_change, :validate, on: :update, changed: :type_id do
  return unless (c = dup) && c.action == :create && !c.valid?

  errors.add :type, t(:core_error_cant_change_errors,
                      name: name,
                      type_id: type_id,
                      error_messages: c.errors.full_messages)
end

event :validate_type, :validate, changed: :type_id, on: :save do
  errors.add :type, t(:core_error_no_such_type) unless type_name

  if (rt = structure) && rt.assigns_type? && type_id != rt.type_id
    errors.add :type, t(:core_error_hard_templated, name: name, type_name: rt.type_name)
  end
end

def type_card
  Card.quick_fetch type_id.to_i unless type_id.nil?
end

def type_code
  Card::Codename[type_id.to_i]
end

def type_name
  type_card.try :name
end

alias_method :type, :type_name

def type_name_or_default
  type_card.try(:name) || Card.quick_fetch(Card.default_type_id).name
end

def type_cardname
  type_card.try :name
end

def type= type_name
  self.type_id = type_name.card_id
end

def type_id= card_or_id
  write_card_or_id :type_id, card_or_id
end

private

def ensure_type_id lookup
  return if lookup == :skip || (type_id && (lookup != force))

  new_type_id = type_id_from_code || type_id_from_template

  reset_patterns if new_type_id != type_id
  self.type_id = new_type_id
end

def type_id_from_code

end

def type_id_from_template
  name && template&.type_id
end
