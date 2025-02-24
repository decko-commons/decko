format :html do
  wrapper :email_document do
    <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <meta http-equiv="Content-type" content="text/html;charset=UTF-8"/>
          <style>#{email_styles}</style>
        </head>
        <body class="d0-email-body">
          #{interior}
        </body>
      </html>
    HTML
  end

  def email_styles
    :email_stylesheet.card.format(:css).render_compiled
  end

  view :email_page, wrap: :email_document do
    render_core
  end
end

format :email_html do
  def show context
    content = contextual_content context
    return unless content.present?

    wrap_with_email_document content
  end

  view :unknown do
    ""
  end

  view :compact_missing do
    ""
  end
end
