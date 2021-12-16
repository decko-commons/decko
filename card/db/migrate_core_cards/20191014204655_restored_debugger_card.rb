# -*- encoding : utf-8 -*-

class RestoredDebuggerCard < Card::Migration::Core
  def up
    ensure_code_card "*debugger", codename: "debugger", type_id: Card::SessionID
  end
end
