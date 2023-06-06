# -*- encoding : utf-8 -*-

class AddMarkdownType < Cardio::Migration
  def up
    Card.ensure name: "Markdown", codename: "markdown", type_id: Card::CardtypeID
  end
end
