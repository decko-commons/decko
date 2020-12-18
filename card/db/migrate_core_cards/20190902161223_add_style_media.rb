# -*- encoding : utf-8 -*-

class AddStyleMedia < Cardio::Migration::Core
  def up
    ensure_card "style: media", codename: "style_media", type_id: Card::ScssID
  end
end
