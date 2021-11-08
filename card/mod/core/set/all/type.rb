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
  return if lookup == :skip || (type_id && (lookup != :force))

  old_type_id = type_id
  new_type_id = type_id_from_code || type_id_from_template

  reset_patterns if new_type_id != old_type_id
  self.type_id = new_type_id
end

def type_id_from_code
  return if simple?
  each_type_assigning_module_key do |module_key|
    type_id = Card::Set::Type.assignment[module_key]
    return type_id if type_id
  end
  nil
end

def type_id_from_template
  name && template&.type_id
end

def normalize_type_attributes args
  new_type_id = extract_type_id! args unless args.delete(:type_lookup) == :skip
  args[:type_id] = new_type_id if new_type_id
end

def extract_type_id! args={}
  case
  when (type_id = args.delete(:type_id)&.to_i)
    type_id.zero? ? nil : type_id
  when (type_code = args.delete(:type_code)&.to_sym)
    type_id_from_codename type_code
  when (type_name = args.delete :type)
    type_id_from_cardname type_name
  end
end

def type_id_from_codename type_code
  type_id_or_error(type_code) { Card::Codename.id type_code }
end

def type_id_from_cardname type_name
  type_id_or_error(type_name) { type_name.card_id }
end

def type_id_or_error val
  type_id = yield
  return type_id if type_id

  errors.add :type, "#{val} is not a known type."
  nil
end
