format :html do
  def edit_fields
    EmailTemplate::EmailConfig::EMAIL_FIELDS + [:test_context]
  end

  view :core do
    render_read_form
  end
end
