include_set Abstract::AccountField

assign_type :phrase

def history?
  false
end

def ok_to_read
  own_account? || super
end

event :encrypt_password, :store, on: :save, changed: :content do
  salt = left&.salt
  self.content = Auth.encrypt content, salt

  # errors.add :password, 'need a valid salt'
  # turns out we have a lot of existing account without a salt.
  # not sure when that broke??
end

event :validate_password, :validate, on: :save do
  return if content.length > 3

  errors.add :password, t(:account_password_length)
end

event :validate_password_present, :prepare_to_validate, on: :update do
  abort :success if content.blank?
end

view :raw do
  t :account_encrypted
end

format :html do
  view :core, wrap: :em do
    render_raw
  end

  def input_type
    :password
  end

  def password_input
    haml :password_input
  end

  view :input do
    password_input
  end

  def autocomplete?
    return "on" if @parent && @parent.card.name == "*signin+*account" # HACK

    "off"
  end
end
