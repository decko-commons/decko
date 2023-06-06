# -*- encoding : utf-8 -*-

class AddPointerCards < Cardio::Migration
  def up
    Card.ensure name: "script: pointer config",
                type_id: Card::CoffeeScriptID,
                codename: "script_pointer_config"
  end
end
