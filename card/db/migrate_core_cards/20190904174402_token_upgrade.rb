# -*- encoding : utf-8 -*-

class TokenUpgrade < Card::Migration::Core
  def up
    update_card :token, name: "*api key", codename: "api_key", update_referers: true
    delete_code_card :expiration
  end
end
