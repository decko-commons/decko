# -*- encoding : utf-8 -*-

class RepairAllReferences < Cardio::Migration
  def up
    Card::Reference.repair_all
  end
end
