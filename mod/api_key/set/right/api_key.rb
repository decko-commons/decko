include_set Abstract::AccountField

# triggerable event to generate new API Key
event :generate_api_key, :prepare_to_validate, trigger: :required do
  generate
end

event :validate_api_key, :validate, on: :save, changed: :content do
  errors.add :content, t(:api_key_invalid) unless content.match?(/^\w{20,}$/)
  errors.add :content, t(:api_key_taken) if api_key_taken?
end

# checks availability of API key
def api_key_taken?
  return false unless (acct = Card::Auth.find_account_by_api_key content)

  acct.id != left_id
end

def history?
  false
end

def ok_to_read?
  own_account? || super
end

def ok_to_create
  own_account? || super
end

# @return [True/False] checks whether key matches content
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

def simple_token
  Card::Auth::Token.encode accounted.id
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

format :json do
  view :token do
    { token: card.simple_token }
  end
end

format :html do
  view :core, unknown: true, template: :haml
  view(:content, unknown: true) { super() }

  %i[titled titled_content].each do |viewname|
    view(viewname, unknown: true) { super() }
  end

  view :token_link do
    link_to t(:api_key_get_jwt_token), path: { format: :json, view: :token }
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

  def input_type
    :text_field
  end
end
