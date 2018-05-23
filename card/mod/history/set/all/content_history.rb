
# if these aren't in a nested module, the methods just overwrite the base
#  methods, but we need a distict module so that super will be able to refer to
# the base methods.
def content
  @selected_action_id ? selected_content : super
end

def selected_content
  @selected_content ||= content_at_time_of_selected_action || db_content
end

def content_at_time_of_selected_action
  last_change_on(:db_content, not_after: @selected_action_id, including_drafts: true)&.value
end

def content= value
  @selected_content = nil
  super
end

def save_content_draft content
  super
  acts.create do |act|
    act.ar_actions.build(draft: true, card_id: id, action_type: :update)
       .card_changes.build(field: :db_content, value: content)
  end
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
    Change.joins(:action).where(
      last_change_sql_conditions(opts),
      card_id: id,
      action_id: action_id,
      field: Card::Change.field_index(field)
    ).order(:id).last
  end
end

def extract_action_id action_arg
  action_arg.is_a?(Card::Action) ? action_arg.id : action_arg
end

def last_change_sql_conditions opts
  cond = "card_actions.card_id = :card_id AND field = :field"
  cond += " AND (draft is not true)" unless opts[:including_drafts]
  operator = "<" if opts[:before]
  operator = "<=" if opts[:not_after]
  cond += " AND card_action_id #{operator} :action_id" if operator
  cond
end

def selected_action_id
  @selected_action_id || (@current_action && @current_action.id) ||
    last_action_id
end

def selected_action_id= action_id
  @selected_content = nil
  @selected_action_id = action_id
end

def selected_action
  selected_action_id && Action.fetch(selected_action_id)
end

def with_selected_action_id action_id
  current_action_id = @selected_action_id
  select_action_id action_id
  result = yield
  select_action_id current_action_id
  result
end

def select_action_id action_id
  run_callbacks :select_action do
    self.selected_action_id = action_id
  end
end

def selected_content_action_id
  @selected_action_id || new_content_action_id || last_content_action_id
end

def new_content_action_id
  return unless @current_action && current_action_changes_content?
  @current_action.id
end

def current_action_changes_content?
  new_card? || @current_action.new_content? || db_content_is_changing?
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

def acted_at
  last_act.acted_at
end

def previous_action action_id
  return unless action_id
  action_index = actions.find_index { |a| a.id == action_id }
  all_actions[action_index - 1] if action_index.to_i.nonzero?
end

def revised_at
  (last_action && (act = last_action.act) && act.acted_at) || Time.zone.now
end

def creator
  Card[creator_id]
end

def updater
  Card[updater_id]
end

def clean_html?
  true
end

def draft_acts
  drafts.created_by(Card::Auth.current_id).map(&:act)
end

event :detect_conflict, :validate, on: :update, when: :edit_conflict? do
  errors.add :conflict, "changes not based on latest revision"
end

def edit_conflict?
  last_action_id_before_edit &&
    last_action_id_before_edit.to_i != last_action_id &&
    (la = last_action) &&
    la.act.actor_id != Auth.current_id
end
