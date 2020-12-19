# -*- encoding : utf-8 -*-

class DeleteMachineOutput < Cardio::Migration::Core
  def up
    Card.search(right: { codename: "machine_output" }).each(&:delete!)
  end
end
