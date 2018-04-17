EMAIL_FIELDS =
  %i[to from cc bcc attach subject text_message html_message].freeze

EMAIL_FIELD_METHODS =
  { subject: :contextual_content,
    text_message: :contextual_content,
    attach: :extended_item_contents }.freeze

def email_config context, fields={}, auth_user=nil
  @active_email_context = context || self
  config = EMAIL_FIELDS.each_with_object({}) do |field, conf|
    conf[field] = fields[key] || email_field_from_card(field, auth_user)
  end
  safe_from_and_reply_to! config
  config.select { |_k, v| v.present? }
end

def email_field_from_card field, auth_user
  return unless (field_card = fetch(trait: field))
  with_email_auth field_card, auth_user do
    special_email_field_method(field, field_card) ||
      standard_email_field(field, field_card)
  end
end

def special_email_field_method field, field_card
  method = "email_#{field}_field"
  return unless respond_to? method
  send method, field_card
end

# FIXME: handle these
#      user = (args[:follower] && Card.fetch(args[:follower])) ||
#             field_card.updater

def with_email_auth field_card, auth_user
  # unless otherwise specified, use permissions of user who last configured field card
  Auth.as((auth_user || field_card.updater)) do
    yield
  end
end

def standard_email_field field, field_card
  method = EMAIL_FIELD_METHODS[field] || :email_addresses
  field_card.format(:email_text).send method, @active_email_context
end

def email_html_message_field message_card
  Proc.new do |mail|
    message_card.format(:email_html).email_content @active_email_context, mail
  end
end

# def process_html_message mail, config, args
#   msg_args = args.merge inline_attachment_url: inline_attachment_lambda(mail)
#   card.process_message_field :html_message, config, msg_args, "email_html"
#   html_message_with_layout config.delete(:html_message)
# end
#
# def inline_attachment_lambda mail
#   # inline attachments require mail object. the current solution is to pass a block
#   # to the view where it is needed to create the image tag
#   # (see inline view in Type::Image::EmailHtmlFormat)
#   # it could make more sense to give the image direct access to the mail object?
#   lambda do |path|
#     mail.attachments.inline[path] = ::File.read path
#     mail.attachments[path].url
#   end
# end

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
    Card[Card::WagnBotID].account.email
  end
end

def configured_from_name_and_email raw_string
  if raw_string =~ /(.*)\<(.*)>/
    [Regexp.last_match(1).strip, Regexp.last_match(2)]
  else
    [nil, raw_string]
  end
end
