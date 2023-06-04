# -*- encoding : utf-8 -*-

class PartialReferenceType < Cardio::Migration::TransformMigration
  def up
    Card::Reference.repair_all
  end
end
