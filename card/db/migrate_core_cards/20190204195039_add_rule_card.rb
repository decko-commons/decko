# -*- encoding : utf-8 -*-

class AddRuleCard < Card::Migration::Core
  def up
    ensure_card "*rule", codename: "rule", type_id: Card::SetID
  end
end
