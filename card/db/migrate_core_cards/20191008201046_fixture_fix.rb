# -*- encoding : utf-8 -*-

class FixtureFix < Card::Migration::Core
  def up
    set_name = ["*header", :self]
    set_card = ensure_card Card::Name[set_name] # set missing
    if (rule_card = Card[[set_name, :read]])
      rule_card.update! left_id: set_card.id
    end
  end
end
