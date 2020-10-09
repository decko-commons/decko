event :set_recaptcha_proxy, :finalize do
  Cardio.config.recaptcha_proxy = content
end
