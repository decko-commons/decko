# -*- encoding : utf-8 -*-

class PartialReferenceType < Cardio::Migration::Core
  def up
    Card::Reference.repair_all
  end
end
