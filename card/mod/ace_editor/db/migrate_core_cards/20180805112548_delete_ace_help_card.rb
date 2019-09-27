# -*- encoding : utf-8 -*-

class DeleteAceHelpCard < Card::Migration
  def up
    delete_card "*Ace+*self+*help"
    update_card! "*Ace", type_id: Card::JsonID
  end
end
