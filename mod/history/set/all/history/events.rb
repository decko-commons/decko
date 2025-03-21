event :update_ancestor_timestamps, :integrate do
  ids = history_ancestor_ids
  return unless ids.present?

  Card.where(id: ids).update_all(updater_id: Auth.current_id, updated_at: Time.now)
  ids.map { |anc_id| Card.expire anc_id.cardname }
end

# event :update_temporary_cache, :initialize do
#   Card.cache.temp.write key, self if key.present?
# end

# must be called on all actions and before :set_name, :process_subcards and
# :delete_children
event :assign_action, :initialize, when: :actionable? do
  @current_action = new_action
end

event :detect_conflict, :validate, on: :update, when: :edit_conflict? do
  errors.add :conflict, ::I18n.t(:history_error_not_latest_revision)
end

# stores changes in the changes table and assigns them to the current action
# removes the action if there are no changes
event :finalize_action, :finalize, when: :finalize_action? do
  if changed_fields.present?
    @current_action.update! card_id: id

    # NOTE: #last_change_on uses the id to sort by date
    # so the changes for the create changes have to be created before the first change
    store_card_changes_for_create_action if first_change?
    store_card_changes unless first_create?
    # FIXME: a `@current_action.card` call here breaks specs in solid_cache_spec.rb
  elsif @current_action.card_changes.reload.empty?
    @current_action.delete
    @current_action = nil
  end
end

event :rollback_actions, :prepare_to_validate, on: :update, when: :rollback_request? do
  update_args = process_revert_actions
  Env.params["revert_actions"] = nil
  update! update_args
  clear_drafts
  abort :success
end

event :finalize_act, after: :finalize_action, when: :act_card? do
  Card::Director.act.update! card_id: id
end

# can we store an action? (can be overridden, eg in files)
def actionable?
  history?
end

def remove_empty_act?
  act_card? && Director.act&.ar_actions&.reload&.empty?
end

def finalize_action?
  actionable? && current_action
end

def edit_conflict?
  last_action_id_before_edit &&
    last_action_id_before_edit.to_i != last_action_id &&
    (la = last_action) &&
    la.act.actor_id != Auth.current_id
end

private

def new_action
  Card::Action.new(
    act: director.need_act,
    # ar_card: self,
    action_type: action,
    draft: draft_action?,
    super_action: super_action
  )
end

def draft_action?
  Env.params["draft"] == "true"
end

def super_action
  return unless @supercard && @supercard != self

  @supercard.current_action
end

# changes for the create action are stored after the first update
def store_card_changes_for_create_action
  Card::Action.cache.delete "#{create_action.id}-changes"
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
  fields ||= Card::Change::TRACKED_FIELDS
  if false # Card::Change.supports_import?
    # attach.feature fails with this
    values = fields.map.with_index { |field, index| [index, yield(field), action_id] }
    Card::Change.import %i[field value card_action_id], values # , validate: false
  else
    fields.each do |field|
      Card::Change.create field: field,
                          value: yield(field),
                          card_action_id: action_id
    end
  end
end
