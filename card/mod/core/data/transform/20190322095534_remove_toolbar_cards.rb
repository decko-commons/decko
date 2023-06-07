# -*- encoding : utf-8 -*-

class RemoveToolbarCards < Cardio::Migration::Transform
  def up
    delete_code_card :activity_toolbar_button
    delete_code_card :rules_toolbar_button
  end
end
