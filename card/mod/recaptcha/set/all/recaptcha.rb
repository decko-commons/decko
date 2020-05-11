RECAPTCHA_ERROR_CODES = {  # LOCALIZE
  "missing-input-secret" =>	"secret parameter is missing",
  "invalid-input-secret" =>	"secret parameter is invalid or malformed",
  "missing-input-response" =>	"response parameter is missing",
  "invalid-input-response" =>	"response parameter is invalid or malformed",
  "bad-request" =>	"request is invalid or malformed"
}

def human?
  result = JSON.parse recaptcha_response
  return if recaptcha_success?(result)

  add_recaptcha_errors result["error-codes"]
end

def recaptcha_on?
  recaptcha_keys? &&
    Env[:controller] &&
    !Auth.signed_in? &&
    !Auth.always_ok? &&
    !Auth.needs_setup? &&
    Card::Rule.toggle(rule(:captcha))
end

def add_recaptcha_errors error_codes
  if error_codes.present?
    error_codes.each do |code|
      errors.add :recaptcha, RECAPTCHA_ERROR_CODES.fetch(code, code)
    end
  else
    errors.add :recaptcha, "Looks like you are not a human" # LOCALIZE
  end
end

def recaptcha_success? result
  result['success'] &&
    (result['score'].to_f >= Cardio.config.recaptcha_minimum_score) &&
    (result['action'].to_sym == action.to_sym)
end

def recaptcha_response
  ::Recaptcha.get({ secret: Card.config.recaptcha_secret_key,
                    response: Env.params[:recaptcha_token] }, {})
end

def recaptcha_keys?
  Card.config.recaptcha_site_key && Card.config.recaptcha_secret_key
end

event :recaptcha, :validate, when: :validate_recaptcha? do
  handle_recaptcha_config_errors do
    Env[:recaptcha_used] = true
    human?
  end
end

def handle_recaptcha_config_errors
  if Env.params[:recaptcha_token] == "grecaptcha-undefined"
    errors.add "recaptcha", "needs correct v3 configuration" # LOCALILZE
  elsif Env.params[:recaptcha_token] == "recaptcha-token-field-missing"
    raise Card::Error, "recaptcha token field missing" # LOCALILZE
  else
    yield
  end
end


def validate_recaptcha?
  !@supercard && !Env[:recaptcha_used] && recaptcha_on?
end

format :html do
  def recaptcha_token action
    output [
      javascript_include_tag(recaptcha_script_url),
      hidden_field_tag("recaptcha_token", "",
                       "data-site-key": Card.config.recaptcha_site_key,
                       "data-action": action,
                       class: "_recaptcha-token")
    ]
  end

  def recaptcha_script_url
    "https://www.google.com/recaptcha/api.js?render=#{Card.config.recaptcha_site_key}"
  end

  def hidden_form_tags action, opts
    return super unless recaptcha?(opts)

    super + recaptcha_token(action)
  end

  def card_form_html_opts action, opts={}
    super
    opts["data-recaptcha"] ||= "on" if recaptcha?(opts)
    opts
  end

  def recaptcha? opts
    card.recaptcha_on? && opts[:recaptcha] != :off
  end
end
