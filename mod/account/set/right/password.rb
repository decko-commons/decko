include_set Abstract::AccountField

assign_type :phrase

PASSWORD_REGEX = {
  lower: /[a-z]/,
  upper: /[A-Z]/,
  # special_char: /[!"#$%&'()*+,\-\.\/:;<=>?@\[\]\\^_`{|}~]/,
  special_char: /[!$%]/,
  number: /\d+/,
  letter: /[a-zA-Z]/
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

event :validate_password_chars, :validate, on: :save do
  pw_requirements = check_password_regex(
    Cardio.config.account_password_requirements,
    PASSWORD_REGEX,
    content
  )
  return unless pw_requirements

  error_message = consolidated_password_error_message(pw_requirements)
  errors.add :password, t(:account_password_requirements, char_type: error_message)
end

event :validate_password_present, :prepare_to_validate, on: :update do
  abort :success if content.blank?
end

view :raw do
  t :account_encrypted
end

private

def check_password_regex char_types, regex_hash, password
  pw_requirements = []

  char_types.each do |char_type|
    if regex_hash.key?(char_type) && password !~ regex_hash[char_type]
      pw_requirements << :"account_password_requirement_#{char_type}"
    end
  end
  pw_requirements unless pw_requirements.empty?
end

private

def consolidated_password_error_message err_messages
  error_message = err_messages.map { |message| t(message) }
  if error_message.length > 2
    "#{error_message[0...-1].join(', ')}, and #{error_message[-1]}"
  else
    error_message.join(" and ")
  end
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
