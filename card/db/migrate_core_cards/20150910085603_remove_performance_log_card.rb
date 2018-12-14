# -*- encoding : utf-8 -*-

class RemovePerformanceLogCard < Card::Migration::Core
  def up
    if card = Card[:performance_log]
      card.update! codename: nil
      card.delete
    end
  end
end
