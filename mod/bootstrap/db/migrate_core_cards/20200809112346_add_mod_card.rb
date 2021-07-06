# -*- encoding : utf-8 -*-

class AddModCard < Cardio::Migration::Core
  def up
    ensure_code_card "mod: bootstrap", type_id: Card::ModID
  end
end
