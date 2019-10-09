# -*- encoding : utf-8 -*-

class FixtureFix < Card::Migration::Core
  def up
    set_name = ["*header", :self]
    set_card = ensure_card Card::Name[set_name] # set missing
    Card[[set_name, :read]].update! left_id: set_card.id
  end
end
