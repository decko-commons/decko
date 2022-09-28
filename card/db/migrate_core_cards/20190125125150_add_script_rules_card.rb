# -*- encoding : utf-8 -*-

class AddScriptRulesCard < Cardio::Migration::Core
  def up
    Card.ensure name: "script: rules",
                type_id: Card::CoffeeScriptID,
                codename: "script_rules"
  end
end
