def consider_recaptcha?
  false
end

format :html do
  view :open do
    voo.show :help
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

  view :core, cache: :never do
    voo.edit_structure = [signin_field(:email), signin_field(:password)]
    with_nest_mode :edit do
      card_form :update, recaptcha: :off do
        [
          hidden_signin_fields,
          _render_content_formgroup,
          _render_signin_buttons
        ]
      end
    end
  end

  def hidden_signin_fields
    hidden_field_tag :success, "REDIRECT: #{Env.interrupted_action || '*previous'}"
  end

  view :signin_buttons do
    button_formgroup do
      [signin_button, signup_link, reset_password_link]
    end
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
    reset_link = link_to_view :edit, text, path: { slot: { hide: :toolbar } }
    # FIXME: inline styling
    raw("<div style='float:right'>#{reset_link}</div>")
  end

  # FORGOT PASSWORD
  view :edit do
    voo.title ||= card.i18n_signin(:forgot_password)
    voo.edit_structure = [signin_field(:email)]
    voo.hide :help
    Auth.as_bot { super() }
  end

  def edit_view_hidden
    hidden_tags(
      reset_password: true,
      success: { view: :reset_password_success }
    )
  end

  view :edit_buttons do
    text = I18n.t :reset_my_password, scope: "mod.account.set.self.signin"
    button_tag text, situation: "primary"
  end

  def signin_field name
    nest_name = "".to_name.trait(name)
    [nest_name, { title: name.to_s, view: "titled",
                  nest_name: nest_name, skip_perms: true }]
  end

  view :reset_password_success do
    # 'Check your email for a link to reset your password'
    frame { I18n.t(:check_email, scope: "mod.account.set.self.signin") }
  end
end

event :signin, :validate, on: :update do
  email = subfield :email
  email &&= email.content
  pword = subfield :password
  pword &&= pword.content

  authenticate_or_abort email, pword
end

def authenticate_or_abort email, pword
  abort :failure, i18n_signin(:abort_bad_signin_args) unless email && pword
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

def i18n_signin key
  I18n.t key, scope: "mod.account.set.self.signin"
end

event :signin_success, after: :signin do
  abort :success
end

event :send_reset_password_token, before: :signin, on: :update,
                                  when: proc { Env.params[:reset_password] } do
  email = subfield :email
  email &&= email.content

  account = Auth.find_account_by_email email
  send_reset_password_email_or_fail account
end

def send_reset_password_email_or_fail account
  if account && account.active?
    account.send_reset_password_token
    abort :success
  elsif account
    errors.add :account, i18n_signin(:error_not_active)
  else
    errors.add :email, i18n_signin(:error_not_recognized)
  end
  abort :failure
end

event :signout, :validate, on: :delete do
  Auth.signin nil
  abort :success
end
