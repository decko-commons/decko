# -*- encoding : utf-8 -*-

class AddCardtypeInputTypes < Cardio::Migration::Core
  def up
    ensure_card %i[input_type right default],
                type_id: Card::PointerID
    ensure_card %i[content_option_view right default],
                type_id: "smart label"
  end
end
