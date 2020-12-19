# -*- encoding : utf-8 -*-

class UpdateCardtypeTypeStructure < Cardio::Migration::Core
  def up
    merge_cards %w[cardtype+*type+*structure Administrator+dashboard Shark+dashboard]
  end
end
