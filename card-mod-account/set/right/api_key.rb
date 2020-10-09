include_set Abstract::AccountField

# DURATIONS = "second|minute|hour|day|week|month|year".freeze

def history?
  false
end

view :raw do
  tr :private_data
end

def validate! api_key
  error =
    case
    when !real?             then [:token_not_found, tr(:error_token_not_found)]
    # when expired?           then [:token_expired, tr(:error_token_expired)]
    when content != api_key then [:incorrect_token, tr(:error_incorrect_token)]
    end
  errors.add(*error) if error
  error.nil?
end

# def expired?
#   !permanent? && updated_at <= term.ago
# end
#
# def permanent?
#   term == "permanent"
# end

# def term
#   @term ||=
#     if expiration.present?
#       term_from_string expiration
#     else
#       Cardio.config.token_expiry
#     end
# end

# def term_from_string string
#   string.strip!
#   return "permanent" if string == "none"
#   re_match = /^(\d+)[\.\s]*(#{DURATIONS})s?$/.match(string)
#   number, unit = re_match.captures if re_match
#   raise Card::Open::Error, tr(:exception_bad_expiration, example: '2 days') unless unit
#   number.to_i.send unit
# end
