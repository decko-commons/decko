# -*- encoding : utf-8 -*-

class AddMarkdownType < Card::Migration
  def up
    ensure_card name: "Markdown", codename: "markdown", type_id: Card::CardtypeID
  end
end
