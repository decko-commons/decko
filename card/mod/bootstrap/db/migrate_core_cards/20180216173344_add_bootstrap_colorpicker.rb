# -*- encoding : utf-8 -*-

class AddBootstrapColorpicker < Card::Migration::Core
  def up
    ensure_card "style: bootstrap colorpicker",
                type_id: Card::ScssID, codename: "style_bootstrap_colorpicker"
  end
end
