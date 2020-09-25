# -*- encoding : utf-8 -*-

class BootstrapCleanup < Card::Migration::Core
  def up
    delete_code_card :bootstrap_breakpoints
    delete_code_card :bootstrap_variables
    delete_code_card :bootstrap_mixins
    ensure_card "script: bootstrap", codename: "script_bootstrap"
    if (card = Card.fetch(:all, :script))
      card.drop_item! "script: bootstrap"
      card.drop_item! "script: jquery helper"
    end
  end
end
