# -*- encoding : utf-8 -*-

class HeadRule < Card::Migration::Core
  def up
    update_card :head, type_id: Card::SettingID
    ensure_card [:all, :head],
                type_id: Card::PointerID,
                content: Card.fetch_name(:head)
    ensure_card [:head, :right, :help],
                content: "head tag content"

  end
end
