# -*- encoding : utf-8 -*-

class AddScriptRulesCard < Card::Migration::Core
  def up
    ensure_card name: "script: rules",
                type_id: Card::CoffeeScriptID,
                codename: "script_rules"
  end
end
