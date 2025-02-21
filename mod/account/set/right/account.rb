# -*- encoding : utf-8 -*-

card_accessor :email
card_accessor :password
card_accessor :salt
card_accessor :status

require_field :email

def own_account?
  accounted&.try :own_account?
end

def accounted
  left
end

def accounted_id
  left_id
end

def ok_to_read?
  own_account? || super
end

# allow account owner to update account field content
def ok_to_update?
  (own_account? && !name_changed? && !type_id_changed?) || super
end

def changes_visible? act
  act.actions_affecting(act.card).each do |action|
    return true if action.card.ok? :read
  end
  false
end

def send_account_email email_template
  ecard = Card[email_template]
  unless ecard&.type_id == EmailTemplateID
    raise Card::Error, "invalid email template: #{email_template}"
  end

  ecard.deliver self, to: email
end

def respond_to_missing? method, _include_private=false
  method.match?(/\?$/) ? true : super
end

def method_missing method, *args
  return super unless args.empty? && (matches = method.match(/^(?<status>.*)\?$/))

  status == matches[:status]
end

