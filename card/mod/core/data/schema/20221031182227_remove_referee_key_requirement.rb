# -*- encoding : utf-8 -*-

class RemoveRefereeKeyRequirement < Cardio::Migration::Schema
  def up
    change_column_null :card_references, :referee_key, true
  end

  def down
    change_column_null :card_references, :referee_key, false
  end
end
