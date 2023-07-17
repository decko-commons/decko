# -*- encoding : utf-8 -*-

class AddCardtypeInputTypes < Cardio::Migration::Transform
  def up
    Card.ensure name: %i[input_type right default],
                type: :pointer
    Card.ensure name: %i[content_option_view right default],
                type_id: "smart label"
  end
end
