# -*- encoding : utf-8 -*-

class DeleteAceHelpCard < Cardio::Migration
  def up
    delete_card "*Ace+*self+*help"
    update_card! "*Ace", type_id: Card::JsonID
  end
end
