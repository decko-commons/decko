# -*- encoding : utf-8 -*-

class AddInputOptionsCodename < Cardio::Migration::Core
  def up
    ensure_card %i[input right options],
                codename: "input_options"
  end
end
