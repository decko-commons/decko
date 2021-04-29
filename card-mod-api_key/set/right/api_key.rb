include_set Abstract::AccountField

event :generate_api_key, :prepare_to_validate, trigger: :required do
  generate
end

event :validate_api_key, :validate do
  errors.add :content, t(:api_key_invalid) unless content.match?(/^\w{20,}$/)
  errors.add :content, t(:api_key_taken) if api_key_taken?
end

def api_key_taken?
  return false unless (acct = Card::Auth.find_account_by_api_key content)
  acct.left_id == left_id
end

def history?
  false
end

def ok_to_read
  own_account? ? true : super
end

def authenticate_api_key api_key
  return true unless (error = api_key_validation_error api_key)

  errors.add error, t(error)
  false
end

def generate
  self.content = SecureRandom.base64.tr "+/=", "Qrt"
end

def generate!
  generate.tap { save! }
end

private

def api_key_validation_error api_key
  case
  when !real?
    :api_key_not_found
  when content != api_key
    :api_key_incorrect
  end
end

format :html do
  view :core, unknown: true, template: :haml

  %i[titled titled_content].each do |viewname|
    view(viewname, unknown: true) { super() }
  end

  view :generate_button, perms: :update, unknown: true do
    text = card.content.present? ? t(:api_key_regenerate) : t(:api_key_generate)
    card_form :update do
      [
        hidden_tags(card: { trigger: :generate_api_key }),
        submit_button(text: text, disable_with: t(:api_key_generating))
      ]
    end
  end
end
