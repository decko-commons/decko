class Cardio::Railtie
  puts "recaptcha called!!!"
  config.recaptcha_public_key = nil  # deprecated; use recaptcha_site_key instead
  config.recaptcha_private_key = nil # deprecated; use recaptcha_secret_key instead

  config.recaptcha_proxy = nil
  config.recaptcha_site_key = nil
  config.recaptcha_secret_key = nil
  config.recaptcha_minimum_score = 0.5
end