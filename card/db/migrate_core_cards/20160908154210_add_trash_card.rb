# -*- encoding : utf-8 -*-

class AddTrashCard < Cardio::Migration::Core
  def up
    create_or_update! name: "*trash", codename: "trash"
  end
end
