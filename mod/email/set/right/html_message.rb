include_set Abstract::TestContext

def clean_html?
  false
end

format :html do
  wrapper :styled_email do
    haml :styled, body: interior
  end

  view :core, wrap: :styled_email do
    super()
  end

  view :email_css do
    ""
  end
end

format :email_html do
  def email_content context
    content = contextual_content context
    return unless content.present?

    Card::Mailer.layout content
  end
end
