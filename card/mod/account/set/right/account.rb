# -*- encoding : utf-8 -*-

card_accessor :email
card_accessor :password
card_accessor :salt
card_accessor :status
card_accessor :token

require_field :email

#### ON CREATE

event :set_default_salt, :prepare_to_validate, on: :create do
  salt = Digest::SHA1.hexdigest "--#{Time.zone.now}--"
  Env[:salt] = salt # HACK!!! need viable mechanism to get this to password
  add_subfield :salt, content: salt
end

event :set_default_status, :prepare_to_validate, on: :create do
  default_status = left&.try(:default_account_status) || "active"
  add_subfield :status, content: default_status
end

event :generate_confirmation_token,
      :prepare_to_store, on: :create, when: :can_approve? do
  add_subfield :token, content: generate_token
end

event :send_account_verification_email, :integrate,
      on: :create, when: proc { |c| c.token.present? } do
  Card[:verification_email].deliver self, to: email
end

# ON UPDATE

# reset password emails contain a link to update the +*account card
# and trigger this event
event :reset_password, :prepare_to_validate, on: :update, trigger: :required do
  reset_password_with_token Env.params[:token]
end

# STANDALONE EVENTS
# only triggered when called directly (as methods)

event :reset_token do
  token = generate_token
  Auth.as_bot { token_card.update! content: token }
  token
end

event :send_welcome_email do
  welcome = Card[:welcome_email]
  welcome.deliver self, to: email if welcome&.type_code == :email_template
end

event :send_reset_password_token do
  reset_token
  Card[:password_reset_email].deliver self, to: email
end

def active?
  status == "active"
end

def blocked?
  status == "blocked"
end

def built_in?
  status == "system"
end

def pending?
  status == "pending"
end

def validate_token! test_token
  token_card.validate! test_token
end

def reset_password_with_token token
  aborting do
    if !token
      errors.add :token, "is required"
    elsif !validate_token!(token)
      # FIXME: This should be an error.
      # However, an error abort will trigger a rollback, so the
      # token reset won't work.  That may be an argument for
      # handling the token update in a separate request?
      success << reset_password_try_again
    else
      success << reset_password_success
    end
  end
end

def refreshed_token
  if token_card.id
    token_card.refresh(true).db_content # TODO: explain why refresh is needed
  else # eg when viewing email template
    "[token]"
  end
end

def can_approve?
  Card.new(type_id: Card.default_accounted_type_id).ok? :create
end

def ok_to_read
  own_account? ? true : super
end

# allow account owner to update account field content
def ok_to_update
  return true if own_account? && !name_changed? && !type_id_changed?

  super
end

def reset_password_success
  # token_card.used!
  Auth.signin left_id
  { id: name, view: :edit }
end

def reset_password_try_again
  message = tr :sorry_email_reset, error_msg: token_card.errors.first.last
  send_reset_password_token
  { id: "_self", view: "message", message: message }
end

def changes_visible? act
  act.actions_affecting(act.card).each do |action|
    return true if action.card.ok? :read
  end
  false
end

format do
  view :verify_url, cache: :never do
    card_url path(token_path_opts.merge(mark: card.name.left))
  end

  view :verify_days, cache: :never do
    (Card.config.token_expiry / 1.day).to_s
  end

  view :reset_password_url do
    card_url path(token_path_opts.merge(card: { trigger: :reset_password }))
  end

  view :reset_password_days do
    (Card.config.token_expiry / 1.day).to_s
  end

  def token_path_opts
    { action: :update, live_token: true, token: card.refreshed_token }
  end
end

format :html do
  view :core do
    [account_field_nest(:email, "email"),
     account_field_nest(:password, "password")]
  end

  def account_field_nest field, title
    field_nest field, title: title, view: :labeled, edit: :inline
  end

  before :content_formgroups do
    voo.edit_structure = [[:email, "email"], [:password, "password"]]
  end
end

format :email do
  def mail context, fields
    super context, fields.reverse_merge(to: card.email)
  end
end
