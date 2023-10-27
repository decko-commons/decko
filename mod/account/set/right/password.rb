include_set Abstract::AccountField

assign_type :phrase

PASSWORD_REGEX_REQ = {
  lower: [/[a-z]/, :account_password_requirement_lower],
  upper: [/[A-Z]/, :account_password_requirement_upper],
  special_char: [/[!@#$%^&*()]/, :account_password_requirement_special_char],
  number: [/\d+/, :account_password_requirement_number]
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
  pw_requirements = []
  char_types.each do |char_type|
    pw_requirements << regex_hash[char_type][1] if regex_hash.key?(char_type) && password !~ regex_hash[char_type][0]
  end
  return pw_requirements if pw_requirements.length > 0
end

event :validate_password_chars, :validate, on: :save do
  pw_requirements = check_password_regex(
    Cardio.config.account_password_requirements,
    PASSWORD_REGEX_REQ,
    content
  )
  return if !pw_requirements

  def format_error_message array_of_strings
    if array_of_strings.length > 2
      error_message = "#{t(array_of_strings)[0...-1].join(', ')}, and #{t(array_of_strings).last}"
    elsif array_of_strings.length == 2
      error_message = "#{t(array_of_strings).first} and #{t(array_of_strings).last}"
    else
      error_message = "#{t(array_of_strings).first}"
    end
    return error_message
  end

  error_message = format_error_message(pw_requirements)

  errors.add :password, t(:account_password_requirements, char_type: error_message)
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

  def autocomplete?
    return "on" if @parent && @parent.card.name == "*signin+*account" # HACK

    "off"
  end
end

