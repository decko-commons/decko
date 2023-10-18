include_set Abstract::AccountField

assign_type :phrase

PASSWORD_REGEX = {
  lower: /[a-z]/,
  upper: /[A-Z]/,
  symbol: /[!@#$%^&*()]/,
  number: /\d+/
}.freeze

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
  # turns out we have a lot of existing accounts without a salt.
  # not sure when that broke??
end

event :validate_password_length, :validate, on: :save do
  min_pw_length = Cardio.config.account_password_length
  return if content.length >= min_pw_length

  errors.add :password, t(:account_password_length, num_char: min_pw_length)
end

def check_password_regex char_types, regex_hash, password
  char_types.each do |char_type|
    return char_type if regex_hash.key?(char_type) && password !~ regex_hash[char_type]
  end
  true
end

event :validate_password_chars, :validate, on: :save do
  result = check_password_regex(
    Cardio.config.account_password_chars,
    PASSWORD_REGEX,
    content
  )
  requirement = ""

  case result
  when :upper then requirement = "an upper case letter"
  when :lower then requirement = "a lower case letter"
  when :number then requirement = "a number"
  when :symbol then requirement = "a special character (!@#$%^&*())"
  else return
  end

  errors.add :password, t(:account_password_chars, char_type: requirement)
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
