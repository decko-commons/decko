
module ClassMethods
  def default_type_id
    @@default_type_id ||= Card[:all].fetch(:default, skip_modules: true).type_id
  end
end

def type_card
  return if type_id.nil?
  Card.quick_fetch type_id.to_i
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

def type_id_from_template
  return unless name && (t = template)
  reset_patterns # still necessary even with new template handling?
  self.type_id = t.type_id
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
