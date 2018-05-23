# -*- encoding : utf-8 -*-

class AddStyleSelect2Card < Card::Migration::Core
  def up
    ensure_card "style: select2",
                type_id: Card::ScssID,
                codename: "style_select2"
  end
end
