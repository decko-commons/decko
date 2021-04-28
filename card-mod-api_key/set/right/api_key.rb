include_set Abstract::AccountField

# DURATIONS = "second|minute|hour|day|week|month|year".freeze

def history?
  false
end

view :raw do
  t :account_private_data
end

def validate! api_key
  error = api_key_validation_error api_key

  errors.add(*error) if error
  error.nil?
end

private

def api_key_validation_error api_key
  case
  when !real?
    [:token_not_found, t(:account_error_token_not_found)]
  when content != api_key
    [:incorrect_token, t(:account_error_incorrect_token)]
  end
end
