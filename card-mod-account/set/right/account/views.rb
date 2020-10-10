format do
  view :verify_url, cache: :never do
    raise Error::PermissionDenied unless card.ok?(:create) || card.action

    token_url :verify_and_activate, anonymous: true
  end

  view :reset_password_url do
    raise Error::PermissionDenied unless card.password_card.ok? :update

    token_url :reset_password
  end

  view :token_expiry do
    "(#{token_expiry_sentence}"
  end

  view :token_days do
    Cardio.config.token_expiry / 1.day
  end

  # DEPRECATED
  view :verify_days, :token_days
  view :reset_password_days, :token_days

  def token_url trigger, extra_payload={}
    card_url path(action: :update,
                  card: { trigger: trigger },
                  token: new_token(extra_payload))
  end

  def token_expiry_sentence
    "Link will expire in #{render_token_days} days"
  end

  def new_token extra_payload
    Auth::Token.encode card.accounted_id, extra_payload
  end
end

format :html do
  view :core do
    [account_field_nest(:email, "email"),
     account_field_nest(:password, "password")]
  end

  def account_field_nest field, title
    field_nest field, title: title, view: :labeled
    # edit: :inline, hide: [:help_link, :bridge_link]
  end

  before :content_formgroups do
    voo.edit_structure = [[:email, "email"], [:password, "password"]]
  end

  view :token_expiry do
    "<p><em>#{token_expiry_sentence}</em></p>"
  end
end

format :email do
  def mail context, fields
    super context, fields.reverse_merge(to: card.email)
  end
end
