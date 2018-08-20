
def acted_at
  last_act.acted_at
end

def revised_at
  (last_action && (act = last_action.act) && act.acted_at) || Time.zone.now
end

def last_change_on field, opts={}
  action_id = extract_action_id(opts[:before] || opts[:not_after])

  # If there is only one action then there are no entries in the changes table,
  # so we can't do a sql search but the changes are accessible via the action.
  if action_id == create_action.id
    return if opts[:before] # there is no before the first action
    create_action.change field
  elsif !action_id && create_action.sole?
    create_action.change field
  else
    last_change_from_action_id action_id, field, opts
  end
end

def last_change_from_action_id action_id, field, opts
  Change.joins(:action).where(
    last_change_sql_conditions(opts),
    card_id: id,
    action_id: action_id,
    field: Card::Change.field_index(field)
  ).order(:id).last
end

def last_change_sql_conditions opts
  cond = "card_actions.card_id = :card_id AND field = :field"
  cond += " AND (draft is not true)" unless opts[:including_drafts]
  operator = "<" if opts[:before]
  operator = "<=" if opts[:not_after]
  cond += " AND card_action_id #{operator} :action_id" if operator
  cond
end

def last_action_id
  last_action&.id
end

def last_action
  actions.where("id IS NOT NULL").last
end

def last_content_action
  last_change_on(:db_content)&.action
end

def last_content_action_id
  last_change_on(:db_content)&.card_action_id
end

def last_actor
  last_act.actor
end

def last_act
  @last_act ||=
    if (action = last_action)
      last_act_on_self = acts.last
      act_of_last_action = action.act
      return act_of_last_action unless last_act_on_self
      return last_act_on_self unless act_of_last_action

      return last_act_on_self if act_of_last_action == last_act_on_self
      if last_act_on_self.acted_at > act_of_last_action.acted_at
        last_act_on_self
      else
        act_of_last_action
      end
    end
end

def previous_action action_id
  return unless action_id
  action_index = actions.find_index { |a| a.id == action_id }
  all_actions[action_index - 1] if action_index.to_i.nonzero?
end

private

def extract_action_id action_arg
  action_arg.is_a?(Card::Action) ? action_arg.id : action_arg
end