# The Sign In card manages logging in and out of the site.
#
# /:signin (core view) gives the login ui
# /:signin?view=edit gives the forgot password ui

# /update/:signin is the login action
# /delete/:signin is the logout action

# authentication event
event :signin, :validate, on: :update do
  email = subfield :email
  email &&= email.content
  pword = subfield :password
  pword &&= pword.content

  authenticate_or_abort email, pword
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
  email = subfield(:email)&.content
  send_reset_password_email_or_fail email
end

def ok_to_read
  true
end

def consider_recaptcha?
  false
end

def i18n_signin key
  I18n.t key, scope: "mod.account.set.self.signin"
end

def authenticate_or_abort email, pword
  abort :failure, i18n_signin(:email_missing) unless email
  abort :failure, i18n_signin(:password_missing) unless pword
  if (account = Auth.authenticate(email, pword))
    Auth.signin account.left_id
  else
    account = Auth.find_account_by_email email
    errors.add :signin, signin_error_message(account)
    abort :failure
  end
end

def signin_error_message account
  case
  when account.nil?     then i18n_signin(:error_unknown_email)
  when !account.active? then i18n_signin(:error_not_active)
  else                       i18n_signin(:error_wrong_password)
  end
end

def send_reset_password_email_or_fail email
  aborting do
    break errors.add :email, i18n_signin(:error_blank) if email.blank?

    if (account = Auth.find_account_by_email(email))&.active?
      account.send_reset_password_token
    elsif account
      errors.add :account, i18n_signin(:error_not_active)
    else
      errors.add :email, i18n_signin(:error_not_recognized)
    end
  end
end

format :html do
  view :core, cache: :never do
    voo.edit_structure = [signin_field(:email), signin_field(:password)]
    with_nest_mode :edit do
      card_form :update, recaptcha: :off, success: signin_success do
        [
          _render_content_formgroup,
          _render_signin_buttons
        ]
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
    voo.title ||= I18n.t(:sign_in_title, scope: "mod.account.set.self.signin")
    super()
  end

  view :open_content do
    # annoying step designed to avoid table of contents.  sigh
    _render_core
  end

  view :closed_content do
    ""
  end

  view :reset_password_success do
    # 'Check your email for a link to reset your password'
    frame { I18n.t(:check_email, scope: "mod.account.set.self.signin") }
  end

  view :signin_buttons do
    button_formgroup do
      [signin_button, signup_link, reset_password_link]
    end
  end

  # FORGOT PASSWORD
  view :edit do
    reset_password_voo
    Auth.as_bot { super() }
  end

  def reset_password_voo
    voo.title ||= card.i18n_signin(:forgot_password)
    voo.edit_structure = [signin_field(:email)]
    voo.hide :help
  end

  view :edit_buttons do
    text = I18n.t :reset_my_password, scope: "mod.account.set.self.signin"
    button_tag text, situation: "primary", class: "_close-modal-on-success"
  end

  def signin_success
    "REDIRECT: #{Env.interrupted_action || '*previous'}"
  end

  def signin_button
    text = I18n.t :sign_in, scope: "mod.account.set.self.signin"
    button_tag text, situation: "primary"
  end

  def signup_link
    text = I18n.t :or_sign_up, scope: "mod.account.set.self.signin"
    subformat(Card[:account_links]).render! :sign_up, title: text
  end

  def reset_password_link
    text = I18n.t :reset_password, scope: "mod.account.set.self.signin"
    link = link_to_view :edit, text, path: { slot: { hide: :bridge_link } }
    # FIXME: inline styling
    raw("<div style='float:right'>#{link}</div>")
  end

  def edit_view_hidden
    hidden_tags card: { trigger: :send_reset_password_token }
  end

  def edit_success
    { view: :reset_password_success }
  end

  def signin_field name
    nest_name = "".to_name.trait(name)
    [nest_name, { title: name.to_s, view: "titled",
                  nest_name: nest_name, skip_perms: true }]
  end
end
