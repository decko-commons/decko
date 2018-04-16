format :html do
  def decko_variables
    super.merge "decko.recaptchaKey": Card.config.recaptcha_public_key
  end

  view :recaptcha_javascript_tag, tags: :unknown_ok do
    javascript_include_tag "https://www.google.com/recaptcha/api.js", async: "", defer: ""
  end

  def views_in_head
    super << :recaptcha_javascript_tag
  end
end
