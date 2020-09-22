# -*- encoding : utf-8 -*-

class AddNestListType < Card::Migration::Core
  def up
    ensure_code_card "nest list", type_id: Card::CardtypeID
  end
end
x