# -*- encoding : utf-8 -*-

class AddCardtypeInputTypes < Card::Migration::Core
  def up
    ensure_card [:pointer, :input_type]
  end
end
