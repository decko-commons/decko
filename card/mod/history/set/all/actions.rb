# -*- encoding : utf-8 -*-

# must be called on all actions and before :set_name, :process_subcards and
# :validate_delete_children
event :assign_action, :initialize, when: :actionable? do
  act = director.need_act
  @current_action = Card::Action.create(
    card_act_id: act.id,
    action_type: @action,
    draft: (Env.params["draft"] == "true")
  )
  if @supercard && @supercard != self
    @current_action.super_action = @supercard.current_action
  end
end

# can we store an action?
def actionable?
  history?
end

# stores changes in the changes table and assigns them to the current action
# removes the action if there are no changes
event :finalize_action, :finalize, when: :finalize_action? do
  if changed_fields.present?
    @current_action.update_attributes! card_id: id

    # Note: #last_change_on uses the id to sort by date
    # so the changes for the create changes have to be created before the first change
    store_card_changes_for_create_action if first_change?
    store_card_changes if @current_action.action_type != :create
  elsif @current_action.card_changes.reload.empty?
    @current_action.delete
    @current_action = nil
  end
end

def finalize_action?
  actionable? && current_action
end

event :rollback_actions, :prepare_to_validate, on: :update, when: :rollback_request? do
  update_args = process_revert_actions
  Env.params["revert_actions"] = nil
  update_attributes! update_args
  clear_drafts
  abort :success
end

def rollback_request?
  history? && actions_to_revert.any?
end

def process_revert_actions
  update_args = { subcards: {} }
  reverting_to_previous = Env.params["revert_to"] == "previous"
  actions_to_revert.each do |action|
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
  # revision id is probably a mod (e.g. if you request
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

def revision action, before_action=false
  # a "revision" refers to the state of all tracked fields
  # at the time of a given action
  action = Card::Action.fetch(action) if action.is_a? Integer
  return unless action
  return revision_before_action action if before_action
  Card::Change::TRACKED_FIELDS.each_with_object({}) do |field, attr_changes|
    last_change = action.change(field) ||
                  last_change_on(field, not_after: action)
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

# Delete all changes and old actions and make the last action the create action
# (that way the changes for that action will be created with the first update)
def make_last_action_the_initial_action
  delete_all_changes
  old_actions.delete_all
  last_action.update_attributes! action_type: :create
end

# # moves for every field the last change to the last action and deletes all other actions
# def clear_history
#   Card::Change::TRACKED_FIELDS.each do |field|
#       # assign previous changes on each tracked field to the last action
#       next unless (la = last_action) && !la.change(field).present? &&
#                   (last_change = last_change_on field)
#       # last_change comes as readonly record
#       last_change = Card::Change.find(last_change.id)
#       last_change.update_attributes!(card_action_id: last_action_id)
#   end
#   delete_old_action
# end

def clear_history
  delete_all_changes
  delete_old_actions
end

def delete_old_actions
  old_actions.delete_all
end

def delete_all_changes
  Card::Change.where(card_action_id: Card::Action.where(card_id: id).pluck(:id)).delete_all
end

def old_actions
  actions.where("id != ?", last_action_id)
end

def create_action
  @create_action ||= actions.first
end

# changes for the create action are stored after the first update
def store_card_changes_for_create_action
  Card::Change::TRACKED_FIELDS.each do |f|
    Card::Change.create field: f,
                        value: attribute_before_act(f),
                        card_action_id: create_action.id
  end
end

def store_card_changes
  # FIXME: should be one bulk insert
  changed_fields.each do |f|
    Card::Change.create field: f,
                        value: self[f],
                        card_action_id: @current_action.id
  end
end
