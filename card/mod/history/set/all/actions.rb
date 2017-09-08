# -*- encoding : utf-8 -*-

def select_action_by_params params
  return unless (action = find_action_by_params(params))
  run_callbacks :select_action do
    self.selected_action_id = action.id
  end
end

def find_action_by_params args
  if args[:rev]
    nth_action args[:rev]
  elsif args[:rev_id].is_a?(Integer) || args[:rev_id] =~ /^\d+$/
    if (action = Action.fetch(args[:rev_id])) && action.card_id == id
      action
    end
  # revision id is probalby a mod (e.g. if you request
  # files/:logo/standard.png)
  elsif args[:rev_id]
    last_action
  end
end

def nth_action index
  index = index.to_i
  return unless id && index > 0
  Action.where("draft is not true AND card_id = #{id}")
        .order(:id).limit(1).offset(index - 1).first
end

def revision action
  # a "revision" refers to the state of all tracked fields
  # at the time of a given action
  action = Card::Action.fetch(action) if action.is_a? Integer
  return unless action
  Card::Change::TRACKED_FIELDS.each_with_object({}) do |field, attr_changes|
    last_change = action.change(field) ||
                  last_change_on(field, not_after: action)
    attr_changes[field.to_sym] = (last_change ? last_change.value : self[field])
  end
end


# Delete all changes and old actions and make the last action the create action
# (that way the changes for that action will be created with the first update)
def make_last_action_the_initial_action
  delete_all_changes
  old_actions.delete_all
  last_action.update_attributes! action_type: :create
end

# moves for every field the last change to the last action and deletes all other actions
def clear_history
  Card::Change::TRACKED_FIELDS.each do |field|
      # assign previous changes on each tracked field to the last action
      next unless (la = last_action) && !la.change(field).present? &&
                  (last_change = last_change_on field)
      # last_change comes as readonly record
      last_change = Card::Change.find(last_change.id)
      last_change.update_attributes!(card_action_id: last_action_id)
  end
  delete_old_action
end

def delete_old_actions
  old_actions.delete_all
end

def delete_all_changes
  Card::Change.where(action_id: Card::Action.where(card_id: id).pluck(:id)).delete_all
end

def old_actions
  actions.where("id != ?", last_action_id)
end
