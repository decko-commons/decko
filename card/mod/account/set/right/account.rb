# -*- encoding : utf-8 -*-

include All::Permissions::Accounts

card_accessor :email
card_accessor :password
card_accessor :salt
card_accessor :status
card_accessor :token

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
  tcard = token_card
  tcard.validate! test_token
  copy_errors tcard
  errors.empty?
end

def refreshed_token
  if token_card.id
    token_card.refresh(true).db_content # TODO: explain why refresh is needed
  else # eg when viewing email template
    "[token]"
  end
end

format do
  view :verify_url, cache: :never do
    card_url path({ mark: card.name.left }.merge(token_path_opts))
  end

  view :verify_days, cache: :never do
    (Card.config.token_expiry / 1.day).to_s
  end

  view :reset_password_url do
    card_url path({ mark: card, event: :reset_password }.merge(token_path_opts))
  end

  def token_path_opts
    { action: :update, live_token: true, token: card.refreshed_token }
  end

  view :reset_password_days do
    (Card.config.token_expiry / 1.day).to_s
  end
end

format :html do
  view :raw do
    # FIXME: use field_nest instead of parsing content
    # Problem: when you do that then the fields are missing in the sign up form:
    # output( [field_nest(:email, view: :titled, title: "email"),
    #          field_nest(:password, view: :titled, title: "password")])
    %({{+#{:email.cardname}|titled;title:email}}
      {{+#{:password.cardname}|titled;title:password}})
  end

  view :edit do
    voo.structure = true
    voo.edit_structure = [[:email, "email"], [:password, "password"]]
    super()
  end

  view :edit_in_form do
    voo.structure = true
    voo.edit_structure = [[:email, "email"], [:password, "password"]]
    super()
  end
end

event :validate_accountability, :prepare_to_validate, on: :create do
  unless left && left.accountable?
    errors.add :content, tr(:error_not_allowed)
  end
end

event :require_email, :prepare_to_validate,
      after: :validate_accountability, on: :create do
  errors.add :email, "required" unless subfield(:email)
end

event :set_default_salt, :prepare_to_validate, on: :create do
  salt = Digest::SHA1.hexdigest "--#{Time.zone.now}--"
  Env[:salt] = salt # HACK!!! need viable mechanism to get this to password
  add_subfield :salt, content: salt
end

event :set_default_status, :prepare_to_validate, on: :create do
  default_status = Auth.needs_setup? ? "active" : "pending"
  add_subfield :status, content: default_status
end

def can_approve?
  Card.new(type_id: Card.default_accounted_type_id).ok? :create
end

event :generate_confirmation_token,
      :prepare_to_store, on: :create, when: :can_approve? do
  add_subfield :token, content: generate_token
end

event :reset_password,
      :prepare_to_validate, on: :update, when: :reset_password? do
  valid = validate_token! @env_token
  success << (valid ? reset_password_success : reset_password_try_again)
  abort :success
end

def reset_password_success
  token_card.used!
  Auth.signin left_id
  { id: left.name,
    view: :related,
    slot: { items: { nest_name: :account.cardname.prepend_joint,
                     view: :edit } } }
end

def reset_password_try_again
  send_reset_password_token
  { id: "_self",
    view: "message",
    message: tr(:sorry_email_reset, error_msg: errors.first.last) }
end

def edit_password_success_args; end

def reset_password?
  @env_token = Env.params[:token]
  @env_token && Env.params[:event] == "reset_password"
end

event :reset_token do
  Auth.as_bot do
    token_card.update_attributes! content: generate_token
  end
end

event :send_welcome_email do
  welcome = Card[:welcome_email]
  welcome.deliver self, to: email if welcome&.type_code == :email_template
end

event :send_account_verification_email, :integrate,
      on: :create, when: proc { |c| c.token.present? } do
  Card[:verification_email].deliver self, to: email
end

event :send_reset_password_token do
  Auth.as_bot do
    token_card.update_attributes! content: generate_token
  end
  Card[:password_reset_email].deliver self, to: email
end

def ok_to_read
  own_account? ? true : super
end

def changes_visible? act
  act.actions_affecting(act.card).each do |action|
    return true if action.card.ok? :read
  end
  false
end

format :email do
  def mail context, fields
    super context, fields.reverse_merge(to: card.email)
  end
end
