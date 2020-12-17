# -*- encoding : utf-8 -*-

class HeadRule < Cardio::Migration::Core
  def up
    update_card! :head, type_id: Card::SettingID
    ensure_card [:all, :head],
                type_id: Card::HtmlID,
                content: "{{*head|core}}"
    ensure_card [:head, :right, :help],
                content: "head tag content"
    ensure_card [:head, :right, :default], type_id: Card::HtmlID

  end
end
