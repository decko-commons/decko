event :validate_recaptcha_field, :validate, when: :recaptcha_setting? do
  return if content.match?(/^[a-zA-Z0-9\-_]*$/)

  errors.add :content, "invalid key" # LOCALIZE
end

event :set_recaptcha_site_key, :finalize, when: :recaptcha_setting? do
  Card.config.send "recaptcha_#{codename}=", content
end

def recaptcha_setting?
  left&.codename == :recaptcha_settings
end
