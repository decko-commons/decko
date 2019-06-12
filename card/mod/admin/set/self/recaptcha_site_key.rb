event :validate_recaptcha_site_key, :validate do
  return if content.match?(/^[a-zA-Z0-9\-_]*$/)

  errors.add :content, "invalid key" # LOCALIZE
end

event :set_recaptcha_site_key, :finalize do
  Card.config.recaptcha_site_key = content
end
