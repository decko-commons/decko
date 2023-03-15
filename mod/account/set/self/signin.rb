# The Sign In card manages logging in and out of the site.
#
# /:signin (core view) gives the login ui
# /:signin?view=edit gives the forgot password ui

# /update/:signin is the login action
# /delete/:signin is the logout action

# authentication event
event :signin, :validate, on: :update do
  authenticate_or_abort field_content(:email), field_content(:password)
end

# abort after successful signin (do not save card)
event :signin_success, after: :signin do
  abort :success
end

event :signout, :validate, on: :delete do
  Env.reset_session
  Auth.signin AnonymousID
  abort :success
end

# triggered by clicking "Reset my Password", this sends out the verification password
# and aborts (does not sign in)
event :send_reset_password_token, before: :signin, on: :update, trigger: :required do
  aborting do
    blank_email? ? break : send_reset_password_email_or_fail
  end
end

def email_from_field
  @email_from_field ||= field_content(:email)
end

def ok_to_read
  true
end

def recaptcha_on?
  false
end

def authenticate_or_abort email, pword
  abort_unless email, :email_missing
  abort_unless pword, :password_missing
  authenticate_and_signin(email, pword) || failed_signin(email)
end

def authenticate_and_signin email, pword
  return unless (account = Auth.authenticate email, pword)

  Auth.signin account.left_id
end

def failed_signin email
  errors.add :signin, signin_error_message(account_for(email))
  abort :failure
end

def abort_unless value, error_key
  abort :failure, t("account_#{error_key}") unless value
end

def signin_error_message account
  t "account_#{signin_error_key account}"
end

def error_on field, error_key
  errors.add field, t("account_#{error_key}")
end

def account_for email
  Auth.find_account_by_email email
end

def send_reset_password_email_or_fail
  if (account = account_for email_from_field)&.active?
    send_reset_password_email account
  else
    reset_password_fail account
  end
end

def blank_email?
  return false if email_from_field.present?

  error_on :email, :error_blank
end

def send_reset_password_email account
  Auth.as_bot { account.send_password_reset_email }
end

def reset_password_fail account
  if account
    error_on :account, :error_not_active
  else
    error_on :email, :error_not_recognized
  end
end

private

def signin_error_key account
  case
  when account.nil?     then :error_unknown_email
  when !account.active? then :error_not_active
  else                       :error_wrong_password
  end
end

format :html do
  before :core do
    voo.edit_structure = [signin_field(:email), signin_field(:password)]
  end

  view :core, cache: :never do
    with_nest_mode :edit do
      card_form :update, recaptcha: :off, success: signin_success do
        haml :core
      end
    end
  end

  view :open do
    voo.show :help
    voo.hide :menu
    super()
  end

  # FIXME: need a generic solution for this
  view :title do
    voo.title ||= t(:account_sign_in_title)
    super()
  end

  view :open_content do
    # annoying step designed to avoid table of contents.  sigh
    _render_core
  end

  view :one_line_content do
    ""
  end

  view :reset_password_success do
    # 'Check your email for a link to reset your password'
    frame { t :account_check_email }
  end

  # FORGOT PASSWORD
  view :edit do
    reset_password_voo
    Auth.as_bot { super() }
  end

  def reset_password_voo
    voo.title ||= t :account_forgot_password
    voo.edit_structure = [signin_field(:email)]
    voo.hide :help
  end

  view :edit_buttons do
    button_tag t(:account_reset_password),
               situation: "primary", class: "_close-modal-on-success"
  end

  def signin_success
    { redirect: true, mark: (Env.interrupted_action || "*previous") }
  end

  def signin_button
    button_tag t(:account_sign_in), situation: "primary"
  end

  def signup_link
    link_to_card :signup, t(:account_or_sign_up),
                 path: { action: :new, mark: :signup }
  end

  def reset_password_link
    link_to_view :edit, t(:account_reset_password),
                 path: { slot: { hide: :bridge_link } }
  end

  def edit_view_hidden
    hidden_tags card: { trigger: :send_reset_password_token }
  end

  def edit_success
    { view: :reset_password_success }
  end

  def signin_field name
    nest_name = "".to_name.field(name)
    [nest_name, { title: name.to_s, view: "titled",
                  nest_name: nest_name, skip_perms: true }]
  end
end
