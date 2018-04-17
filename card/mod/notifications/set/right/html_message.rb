include_set Abstract::TestContext

def clean_html?
  false
end

format :email_html do
  def email_content context, active_mail
    @active_mail = active_mail
    content = contextual_content context
    return unless content.present?
    Card::Mailer.layout content
  end
end
