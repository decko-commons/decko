event :validate_recaptcha_secret_key, :validate do
  return if content.match?(/^[a-zA-Z0-9\-_]*$/)

  errors.add :content, "invalid key" # LOCALIZE
end

event :set_recaptcha_secret_key, :finalize do
  Card.config.recaptcha_secret_key = content
end
