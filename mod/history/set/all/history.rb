# track history (acts, actions, changes) on this card
def history?
  true
end

# all cards whose acts are considered part of this card's history
def history_card_ids
  nestee_ids << id
end

# all cards who are considered updated if this card's was updated
def history_parent_ids
  nester_ids
end

def history_ancestor_ids recursion_level=0
  return [] if recursion_level > 5

  ids = history_parent_ids +
        history_parent_ids.map { |id| Card[id].history_ancestor_ids(recursion_level + 1) }
  ids.flatten
end

# ~~FIXME~~: optimize (no need to instantiate all actions and changes!)
# Nothing is instantiated here. ActiveRecord is much smarter than you think.
# Methods like #empty? and #size make sql queries if their receivers are not already
# loaded -pk
def first_change?
  # = update or delete
  @current_action.action_type != :create && action_count == 2 &&
    create_action.card_changes.empty?
end

def first_create?
  @current_action.action_type == :create && action_count == 1
end

def action_count
  Card::Action.where(card_id: @current_action.card_id).count
end

# card has account that is responsible for prior acts
def has_edits?
  Card::Act.where(actor_id: id).where("card_id IS NOT NULL").present?
end

def changed_fields
  Card::Change::TRACKED_FIELDS & (changed_attribute_names_to_save | saved_changes.keys)
end

def nestee_ids
  requiring_id { @nestee_ids ||= nesting_ids(:referee_id, :referer_id) }
end

def nester_ids
  requiring_id { @nester_ids ||= nesting_ids(:referer_id, :referee_id) }
end

def diff_args
  { diff_format: :text }
end

# Delete all changes and old actions and make the last action the create action
# (that way the changes for that action will be created with the first update)
def make_last_action_the_initial_action
  delete_all_changes
  old_actions.delete_all
  last_action.update! action_type: :create
end

def clear_history
  delete_all_changes
  delete_old_actions
end

def delete_old_actions
  old_actions.delete_all
end

def delete_all_changes
  Card::Change.where(card_action_id: action_ids).delete_all
end

def save_content_draft content
  super
  acts.create do |act|
    act.ar_actions.build(draft: true, card_id: id, action_type: :update)
       .card_changes.build(field: :db_content, value: content)
  end
end

private

def nesting_ids return_field, where_field
  Card::Reference.select(return_field).distinct.where(
    ref_type: "I", where_field => id
  ).pluck(return_field).compact
end

def requiring_id
  id ? yield : (return [])
end
