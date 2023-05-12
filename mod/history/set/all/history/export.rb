format :json do
  def atom
    super.tap { |atom| atom[:acts] = render_acts if voo.explicit_show? :acts }
  end

  view :acts do
    return [] unless card.real?

    card.acts.map do |act|
      act_hash act
    end
  end

  def act_hash act
    {
      act_id: act.id,
      actor_id: act.actor_id,
      acted_at: act.acted_at,
      act_card_id: act.card_id,
      actions: [action_hash(act.action_on(card.id))]
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
