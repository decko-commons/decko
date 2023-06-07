# -*- encoding : utf-8 -*-

class PartialReferenceType < Cardio::Migration::Transform
  def up
    Card::Reference.repair_all
  end
end
