# -*- encoding : utf-8 -*-

class FixNotificationHtmlMessage < Card::Migration::Core
  def up
    codename = :follower_notification_email
    dir = File.join data_path, "mailer"
    html_message = Card[codename].fetch "html_message"
    html_message.update! content: File.read(File.join(dir, "#{codename}.html"))
  end
end
