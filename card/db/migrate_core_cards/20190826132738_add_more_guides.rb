# -*- encoding : utf-8 -*-

class AddMoreGuides < Card::Migration::Core
  def up
    merge_cards %w[Cardtype+*type+*guide *structure+*right+*guide]
  end
end
