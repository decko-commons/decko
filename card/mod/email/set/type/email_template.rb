
def clean_html?
  false
end

def deliver context=nil, fields={}, opts={}
  mail = format.mail context, fields, opts
  mail.deliver
rescue Net::SMTPError => exception
  errors.add :exception, exception.message
end

format do
  def mail context=nil, fields={}, opts={}
    config = card.email_config context, fields, opts
    fmt = self # self is <Mail::Message> within the new_mail block
    Card::Mailer.new_mail config do
      fmt.message_body self, config
      fmt.add_attachments self, config.delete(:attach)
    end
  end

  def message_body mail, config
    config[:html_message] &&= config[:html_message].call mail
    method, args = body_method_and_args config[:html_message].present?,
                                        config[:text_message].present?
    args = Array.wrap(args).map { |arg| config[arg] }
    send method, mail, *args
  end

  def body_method_and_args html, text
    if html && text
      [:text_and_html_message, %i[text_message html_message attach]]
    elsif html
      %i[html_body html_message]
    else
      %i[text_body text_message]
    end
  end

  def text_and_html_message mail, text_message, html_message, attachment_list=nil
    fmt = self
    if attachment_list&.any?
      mail.multipart_mixed text_message, html_message
    else
      mail.text_part { body text_message }
      mail.html_part { fmt.html_body self, html_message }
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
    each_valid_attachment list do |file, index|
      mail.add_file filename: attachment_name(file, index),
                    content: File.read(file.path)
    end
  end

  def each_valid_attachment list
    list.each_with_index do |cardname, index|
      next unless (file = Card[cardname]&.try(:attachment))
      yield file, index
    end
  end

  def attachment_name file, number
    "attachment-#{number + 1}.#{file.extension}"
  end
end
