# -*- encoding : utf-8 -*-

card_accessor :email
card_accessor :password
card_accessor :salt
card_accessor :status

require_field :email

STATUS_OPTIONS = %w[unapproved unverified active blocked].freeze

def own_account?
  accounted&.try :own_account?
end

def current_account?
  accounted&.try :current_account?
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

def send_account_email email_template
  ecard = Card[email_template]
  unless ecard&.type_id == EmailTemplateID
    raise Card::Error, "invalid email template: #{email_template}"
  end

  ecard.deliver self, to: email
end

STATUS_OPTIONS.each do |stat|
  define_method "#{stat}?" do
    status == stat
  end
end
