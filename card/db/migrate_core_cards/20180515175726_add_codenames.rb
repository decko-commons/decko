# -*- encoding : utf-8 -*-

class AddCodenames < Card::Migration::Core
  def up
    ensure_card "follow suggestions", codename: "follow_suggestions", type: "Pointer"
    ensure_card "welcome email", codename: "welcome_email", type: "Email Template"
  end
end
