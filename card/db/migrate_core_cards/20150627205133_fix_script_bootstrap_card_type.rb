# -*- encoding : utf-8 -*-

class FixScriptBootstrapCardType < Cardio::Migration::Core
  def up
    Card[:bootstrap_js].update! type_id: Card::JavaScriptID
  end
end
