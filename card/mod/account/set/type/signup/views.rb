format :html do
  def invitation?
    Auth.signed_in? && card.can_approve?
  end

  view :new do
    voo.title = invitation? ? tr(:invite) : tr(:sign_up)
    super()
  end

  view :content_formgroups do
    [account_formgroups, (card.structure ? edit_slot : "")].join
  end

  view :new_buttons do
    button_formgroup do
      [standard_create_button, invite_button].compact
    end
  end

  def invite_button
    return unless invitation?
    button_tag "Send Invitation", situation: "primary"
  end

  view :core, template: :haml do
    @lines = [signup_line] + account_lines
    @body = process_content _render_raw
  end

  def signup_line
    ["<strong>#{safe_name}</strong>",
     ("was" if invited?),
     "signed up on #{format_date card.created_at}"].compact.join " "
  end

  def invited?
    !self_signup?
  end

  def self_signup?
    card.creator_id == Card::AnonymousID
  end

  def account_lines
    if card.account
      verification_lines
    else
      [tr(:missing_account)]
    end
  end

  def verification_lines
    [verification_sent_line, verification_link_line].compact
  end

  def verification_sent_line
    account = card.account
    return unless account.email_card.ok?(:read)
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
    action = card.account.status == "unverified" ? "Resend" : "Send"
    approval_link "#{action} verification email", :with
  end

  def approve_without_token_link
    approval_link "Approve without verification", :without
  end

  def approval_link text, with_or_without
    return unless card.can_approve?
    link_to_card card, text,
                 path: { action: :update,
                         card: { trigger: "approve_#{with_or_without}_verification" } }
  end

  def deny_link
    return unless card.ok? :delete
    link_to_card card, "Deny and delete", path: { action: :delete }
  end
end
