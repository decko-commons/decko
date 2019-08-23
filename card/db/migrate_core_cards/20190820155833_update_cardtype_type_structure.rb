# -*- encoding : utf-8 -*-

class UpdateCardtypeTypeStructure < Card::Migration::Core
  def up
    merge_cards "cardtype+*type+*structure"
  end
end
