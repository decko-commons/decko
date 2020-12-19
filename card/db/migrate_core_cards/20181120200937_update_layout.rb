# -*- encoding : utf-8 -*-

class UpdateLayout < Cardio::Migration::Core
  def up
    merge_cards ["*header", "*main_menu"]
  end
end