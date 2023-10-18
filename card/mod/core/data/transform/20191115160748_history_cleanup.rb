# -*- encoding : utf-8 -*-

class HistoryCleanup < Cardio::Migration::Transform
  def up
    delete_create_only_changes
  end

  # actions on cards where the create is the _ONLY_ action should not have
  # card_changes
  def delete_create_only_changes
    create_only_actions.pluck(:id).each_slice(200) do |action_ids|
      Card.connection.execute(
        "DELETE from card_changes where card_action_id in (#{action_ids.join ', '})"
      )
    end
  end

  def create_only_actions
    Card::Action.where(%{
      action_type = 0
      AND NOT EXISTS (select * from card_actions ca1
                      where card_actions.card_id = ca1.card_id
                      and action_type <> 0)
    })
  end
end
