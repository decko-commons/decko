# -*- encoding : utf-8 -*-

class AddStyleSelect2Card < Cardio::Migration::Core
  def up
    Card.ensure name: "style: select2",
                type_id: Card::ScssID,
                codename: "style_select2"
  end
end
