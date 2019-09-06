format do
  view :verify_url, cache: :never do
    token_url :verify_and_activate, anonymous: true
  end

  view :reset_password_url do
    token_url :reset_password
  end

  view :token_expiry do
    "(#{token_expiry_sentence}"
  end

  def token_url trigger, extra_payload={}
    card_url path(action: :update,
                  card: { trigger: trigger },
                  token: new_token(extra_payload))
  end

  def token_expiry_sentence
    "Link will expire in #{Card.config.token_expiry / 1.day} days"
  end

  def new_token extra_payload
    Auth::Token.encode accounted_id, extra_payload
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

  view :token_expiry do
    "<p><em>#{token_expiry_sentence}</em></p>"
  end
end

format :email do
  def mail context, fields
    super context, fields.reverse_merge(to: card.email)
  end
end
