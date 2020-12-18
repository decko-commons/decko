# -*- encoding : utf-8 -*-

class RemoveEditToolbarPinned < Cardio::Migration::Core
  def up
    card = Card[:edit_toolbar_pinned]
    card.update! codename: nil
    card.delete
  end
end
