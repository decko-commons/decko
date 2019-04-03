def revision action, before_action=false
  # a "revision" refers to the state of all tracked fields
  # at the time of a given action
  action = Card::Action.fetch(action) if action.is_a? Integer
  return unless action

  if before_action
    revision_before_action action
  else
    revision_attributes action
  end
end

def revision_attributes action
  Card::Change::TRACKED_FIELDS.each_with_object({}) do |field, attr_changes|
    last_change = action.change(field) || last_change_on(field, not_after: action)
    attr_changes[field.to_sym] = (last_change ? last_change.value : self[field])
  end
end

def revision_before_action action
  if (prev_action = action.previous_action)
    revision prev_action
  else
    { trash: true }
  end
end

def rollback_request?
  history? && actions_to_revert.any?
end

def process_revert_actions revert_actions=nil
  revert_actions ||= actions_to_revert
  update_args = { subcards: {} }
  reverting_to_previous = Env.params["revert_to"] == "previous"
  revert_actions.each do |action|
    merge_revert_action! action, update_args, reverting_to_previous
  end
  update_args
end

def actions_to_revert
  Array.wrap(Env.params["revert_actions"]).map do |a_id|
    Action.fetch(a_id) || nil
  end.compact
end

def merge_revert_action! action, update_args, reverting_to_previous
  rev = action.card.revision(action, reverting_to_previous)
  if action.card_id == id
    update_args.merge! rev
  else
    update_args[:subcards][action.card.name] = rev
  end
end
