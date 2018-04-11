format :html do
  def decko_variables
    super.merge "decko.recaptchaKey": Card.config.recaptcha_public_key
  end
end