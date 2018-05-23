format :html do
  def invitation?
    return @invitation unless @invitation.nil?
    @invitation = Auth.signed_in? &&
                  (card.fetch trait: :account, new: {}).can_approve?
    # consider making account a card_accessor?
  end

  view :new do
    voo.title = invitation? ? tr(:invite) : tr(:sign_up)
    super()
  end

  before :name_formgroup do
    voo.help = tr :first_last_help
  end

  view :content_formgroup do
    [account_formgroups, (card.structure ? edit_slot : "")].join
  end

  def hidden_success override=nil
    override = card.rule(:thanks) unless invitation?
    super override
  end

  view :new_buttons do
    button_formgroup do
      [standard_submit_button, invite_button].compact
    end
  end

  def invite_button
    return unless invitation?
    button_tag "Send Invitation", situation: "primary"
  end

  def account_formgroups
    account = card.fetch trait: :account, new: {}
    Auth.as_bot do
      subformat(account)._render :content_formgroup, structure: true
    end
  end

  view :core, template: :haml do
    @lines = [signup_line] + account_lines
    @body = process_content _render_raw
  end

  def signup_line
    [ "<strong>#{safe_name}</strong>",
      ("was" unless anonymous_signup?),
      "signed up on #{format_date card.created_at}"
    ].compact.join " "
  end

  def anonymous_signup?
    card.creator_id == AnonymousID
  end

  def account_lines
    if card.account
      verification_lines
    else
      [tr(:missing_account)]
    end
  end

  def verification_lines
    [ verification_sent_line, verification_link_line].compact
  end

  def verification_sent_line
    account = card.account
    return unless account.token.present? && account.email_card.ok?(:read)
    "A verification email has been sent to #{account.email}"
  end

  def verification_link_line
    links = verification_links
    return if links.empty?
    links.join " "
  end

  def verification_links
    [approve_with_token_link, approve_without_token_link, deny_link].compact
  end

  def approve_with_token_link
    return unless card.account.can_approve?
    token_action = card.account.token.present? ? "Resend" : "Send"
    link_to_card card, "#{token_action} verification email",
                 path: { action: :update, approve_with_token: true }
  end

  def approve_without_token_link
    return unless card.account.can_approve?
    link_to_card card, "Approve without verification",
                 path: { action: :update, approve_without_token: true }
  end

  def deny_link
    return unless card.ok? :delete
    link_to_card card, "Deny and delete", path: { action: :delete }
  end
end

event :activate_by_token, :validate, on: :update,
                                     when: proc { |c| c.has_token? } do
  abort :failure, "no field manipulation mid-activation" if subcards.present?
  # necessary because this performs actions as Wagn Bot
  abort :failure, "no account associated with #{name}" unless account

  account.validate_token! @env_token

  if account.errors.empty?
    account.token_card.used!
    activate_account
    Auth.signin id
    Auth.as_bot # use admin permissions for rest of action
    success << ""
  else
    resend_activation_token
    abort :success
  end
end

def has_token?
  @env_token = Env.params[:token]
end

event :activate_account do
  # FIXME: -- sends email before account is fully activated
  add_subfield :account
  subfield(:account).add_subfield :status, content: "active"
  self.type_id = Card.default_accounted_type_id
  account.send_welcome_email
end

event :approve_with_token, :validate,
      on: :update,
      when: proc { Env.params[:approve_with_token] } do
  abort :failure, "illegal approval" unless account.can_approve?
  account.reset_token
  account.send_account_verification_email
end

event :approve_without_token, :validate,
      on: :update,
      when: proc { Env.params[:approve_without_token] } do
  abort :failure, "illegal approval" unless account.can_approve?
  activate_account
end

event :resend_activation_token do
  account.reset_token
  account.send_account_verification_email
  message = "Please check your email for a new password reset link."
  if account.errors.any?
    message = "Sorry, #{account.errors.first.last}. #{message}"
  end
  success << { id: "_self", view: "message", message: message }
end

def signed_in_as_me_without_password?
  Auth.signed_in? && Auth.current_id == id && account.password.blank?
end

event :redirect_to_edit_password, :finalize,
      on: :update,
      when: proc { |c| c.signed_in_as_me_without_password? } do
  Env.params[:success] = account.edit_password_success_args
end

event :act_as_current_for_integrate_stage, :integrate,
      on: :create do
  Auth.current_id = id
end
