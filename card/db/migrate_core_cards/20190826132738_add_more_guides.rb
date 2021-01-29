# -*- encoding : utf-8 -*-

class AddMoreGuides < Cardio::Migration::Core
  def up
    merge_cards %w[Cardtype+*type+*guide *structure+*right+*guide]
  end
end
