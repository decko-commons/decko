
def clean_html?
  false
end

def deliver args={}
  mail = format.render_mail(args)
  mail.deliver
rescue Net::SMTPError => exception
  errors.add :exception, exception.message
end

format do
  view :mail, perms: :none, cache: :never do |args|
    config = card.email_config args
    fmt = self # self is <Mail::Message> within the new_mail block
    Card::Mailer.new_mail config do
      attachment_list = config.delete :attach
      fmt.message_body self, config, args, attachment_list
      fmt.add_attachments self, attachment_list
    end
  end

  def message_body mail, config, args, attachment_list
    text_message = config.delete :text_message
    html_message = process_html_message mail, config, args
    if text_message.present? && html_message.present?
      text_and_html_message mail, text_message, html_message, attachment_list
    elsif html_message.present?
      html_body mail, html_message
    else
      text_body mail, text_message
    end
  end

  def process_html_message mail, config, args
    msg_args = args.merge inline_attachment_url: inline_attachment_lambda(mail)
    card.process_message_field :html_message, config, msg_args, "email_html"
    html_message_with_layout config.delete(:html_message)
  end

  def inline_attachment_lambda mail
    # inline attachments require mail object. the current solution is to pass a block
    # to the view where it is needed to create the image tag
    # (see inline view in Type::Image::EmailHtmlFormat)
    # it could make more sense to give the image direct access to the mail object?
    lambda do |path|
      mail.attachments.inline[path] = ::File.read path
      mail.attachments[path].url
    end
  end

  def html_message_with_layout msg
    return unless msg.present?
    Card::Mailer.layout msg
  end

  def text_and_html_message mail, text_message, html_message, attachment_list = nil
    fmt = self
    if attachment_list&.any?
      mail.multipart_mixed text_message, html_message
    else
      mail.text_part { body text_message }
      mail.html_part { fmt.html_body mail, html_message }
    end
  end

  def multipart_mixed mail, text_message, html_message
    mail.content_type "multipart/mixed"
    mail.part content_type: "multipart/alternative" do |copy|
      copy.part content_type: "text/plain" do |plain|
        plain.body = text_message
      end
      copy.part content_type: "text/html" do |html|
        html.body = html_message
      end
    end
  end

  def html_body mail, message
    mail.content_type "text/html; charset=UTF-8"
    mail.body message
  end

  def text_body mail, message
    mail.content_type "text/plain; charset=UTF-8"
    mail.text_part { body message }
  end

  def add_attachments mail, list
    return unless list.present?
    list.each_with_index do |cardname, i|
      file_card = Card[cardname]
      next unless file_card&.respond_to? :attachment
      file = file_card.attachment
      mail.add_file filename: attachment_name(file), content: File.read(file.path)
    end
  end

  def attachment_name file
    "attachment-#{i + 1}.#{file.extension}"
  end
end
