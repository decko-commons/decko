# -*- encoding : utf-8 -*-

class AddCardtypeInputTypes < Cardio::Migration::Core
  def up
    ensure_card [:input_type, :right, :default],
                type_id: Card::PointerID
    ensure_card [:content_option_view, :right, :default],
                type_id: "smart label"
  end
end
