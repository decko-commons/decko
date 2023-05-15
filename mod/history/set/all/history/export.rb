format :json do
  def atom
    super.tap do |atom|
      %i[history actions].each do |view|
        atom[view] = render(view) if voo.explicit_show?(view)
      end
    end
  end

  view :history do
    card.real? ? action_hash_list(card.history_actions) : []
  end

  view :actions do
    card.real? ? action_hash_list(card.actions) : []
  end

  def action_hash_list actions
    actions.map do |action|
      act_hash(action.act).merge action_hash(action)
    end
  end

  def act_hash act
    {
      act_id: act.id,
      actor_id: act.actor_id,
      acted_at: act.acted_at,
      act_card_id: act.card_id,
    }
  end

  def action_hash action
    {
      action_id: action.id,
      card_id: action.card_id,
      action_type: action.action_type,
      comment: action.comment,
      changes: changes_hash(action.card_changes)
    }
  end

  def changes_hash changes
    changes.each_with_object({}) do |change, hash|
      hash[change.field] = change.value
    end
  end
end
