# -*- encoding : utf-8 -*-

class RemoveAddHelp < Card::Migration::Core
  def up
    Card.search(right: { codename: "add_help" },
                left: { type_id: Card::SetID }).each do |card|
      next if Card.exists? [card.left, :help]

      ensure_card [card.left, :help], content: card.content
    end
    delete_code_card :add_help
    Card::Cache.reset_all
  end
end
