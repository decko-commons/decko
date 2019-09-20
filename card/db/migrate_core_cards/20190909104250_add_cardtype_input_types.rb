# -*- encoding : utf-8 -*-

class AddCardtypeInputTypes < Card::Migration::Core
  def up
    ensure_card [:input_type, :right, :default],
                type_id: Card::PointerID
  end
end
