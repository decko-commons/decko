
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

# can we store an action? (can be overridden, eg in files)
def actionable?
  history?
end

event :detect_conflict, :validate, on: :update, when: :edit_conflict? do
  errors.add :conflict, tr(:error_not_latest_revision)
end

def edit_conflict?
  last_action_id_before_edit &&
    last_action_id_before_edit.to_i != last_action_id &&
    (la = last_action) &&
    la.act.actor_id != Auth.current_id
end

# stores changes in the changes table and assigns them to the current action
# removes the action if there are no changes
event :finalize_action, :finalize, when: :finalize_action? do
  if changed_fields.present?
    @current_action.update! card_id: id

    # Note: #last_change_on uses the id to sort by date
    # so the changes for the create changes have to be created before the first change
    store_card_changes_for_create_action if first_change?
    store_card_changes if @current_action.action_type != :create
  elsif @current_action.card_changes.reload.empty?
    @current_action.delete
    @current_action = nil
  end
end

# changes for the create action are stored after the first update
def store_card_changes_for_create_action
  store_each_history_field create_action.id do |field|
    attribute_before_act field
  end
end

def store_card_changes
  store_each_history_field @current_action.id, changed_fields do |field|
    self[field]
  end
end

def store_each_history_field action_id, fields=nil
  # FIXME: should be one bulk insert
  fields ||= Card::Change::TRACKED_FIELDS
  fields.each do |field|
    Card::Change.create field: field,
                        value: yield(field),
                        card_action_id: action_id
  end
end

def finalize_action?
  actionable? && current_action
end

event :rollback_actions, :prepare_to_validate, on: :update, when: :rollback_request? do
  update_args = process_revert_actions
  Env.params["revert_actions"] = nil
  update! update_args
  clear_drafts
  abort :success
end

event :finalize_act, after: :finalize_action, when: :act_card? do
  Card::ActManager.act.update! card_id: id
end

event :remove_empty_act, :integrate_with_delay_final, when: :remove_empty_act? do
  # Card::ActManager.act.delete
  # Card::ActManager.act = nil
end

def remove_empty_act?
  act_card? && ActManager.act&.ar_actions&.reload&.empty?
end
