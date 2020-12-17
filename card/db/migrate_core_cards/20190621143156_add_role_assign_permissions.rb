# -*- encoding : utf-8 -*-

class AddRoleAssignPermissions < Cardio::Migration::Core
  def up
    create "Administrator+*members+*self+*update", "Administrator"
    create "Shark+*members+*self+*update", "Administrator"
    create "Help Desk+*members+*self+*update", "Administrator"
  end
end
