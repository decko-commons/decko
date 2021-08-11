# -*- encoding : utf-8 -*-

class TokenUpgrade < Cardio::Migration::Core
  def up
    update_card! :token, name: "*api key", codename: "api_key"
    delete_code_card :expiration

    %i[user signup].each do |type|
      %i[salt status api_key].each do |field|
        Card[[type, :account, field]]&.delete!
      end
    end
  end
end
