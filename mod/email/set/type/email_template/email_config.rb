EMAIL_FIELDS =
  %i[to from cc bcc attach subject text_message html_message].freeze

EMAIL_FIELD_METHODS =
  { subject: :contextual_content,
    text_message: :contextual_content,
    attach: :extended_item_contents }.freeze

# @param context [Card]  the card in whose context all email fields will be interpreted
# @param fields [Hash] override any templated field configurations with hash values
# @param opts [Hash] options for rendering. unknown options become format options
# @option opts [Card, String, Integer] :auth user identifier. render as this user
def email_config context, fields={}, opts={}
  @active_email_context = context || self
  auth = opts.delete :auth
  config = EMAIL_FIELDS.each_with_object({}) do |field, conf|
    conf[field] = fields[field] || email_field_from_card(field, auth, opts)
  end
  safe_from_and_reply_to! config
  config.select { |_k, v| v.present? }
end

def email_field_from_card field, auth, format_opts
  return unless (field_card = fetch(field))

  auth ||= field_card.updater
  special_email_field_method(field, field_card, auth, format_opts) ||
    standard_email_field(field, field_card, auth, format_opts)
end

def special_email_field_method field, field_card, auth, format_opts
  method = "email_#{field}_field"
  return unless respond_to? method

  send method, field_card, auth, format_opts
end

def standard_email_field field, field_card, auth, format_opts
  method = EMAIL_FIELD_METHODS[field] || :email_addresses
  format_opts = format_opts.merge format: :email_text
  Auth.as auth do
    field_card.format(format_opts).send method, @active_email_context
  end
end

# html messages return procs because image attachments can't be properly rendered
# without a mail object. (which isn't available at initial config time)
def email_html_message_field message_card, auth, format_opts
  proc do |mail|
    Auth.as auth do
      format_opts = format_opts.merge format: :email_html, active_mail: mail
      message_card.format(format_opts).email_content @active_email_context
    end
  end
end

# whenever a default "from" field is configured in Card::Mailer, emails are always
# actually "from" that address
def safe_from_and_reply_to! config
  conf_name, conf_email = configured_from_name_and_email config[:from]
  actual_email = Card::Mailer.default[:from] || conf_email
  config[:from] = email_from_field_value conf_name, conf_email, actual_email
  config[:reply_to] ||= actual_email
end

def email_from_field_value conf_name, conf_email, actual_email
  conf_text = conf_name || conf_email
  if conf_text != actual_email
    %("#{conf_text}" <#{actual_email}>)
  elsif actual_email.present?
    actual_email
  else
    Card[WagnBotID].account.email
  end
end

def configured_from_name_and_email raw_string
  if raw_string =~ /(.*)<(.*)>/
    [Regexp.last_match(1).strip, Regexp.last_match(2)]
  else
    [nil, raw_string]
  end
end
