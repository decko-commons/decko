# if these aren't in a nested module, the methods just overwrite the base
#  methods, but we need a distinct module so that super will be able to refer to
# the base methods.
def content
  @selected_action_id ? selected_content : super
end

def content= value
  @selected_content = nil
  super
end

def select_action_by_params params
  action = nth_action(params[:rev]) || action_from_id(params[:rev_id])
  select_action action.id if action
end

def select_action action_id
  run_callbacks :select_action do
    self.selected_action_id = action_id
  end
end

def selected_action_id
  @selected_action_id || @current_action&.id || last_action_id
end

def selected_action_id= action_id
  @selected_content = nil
  @selected_action_id = action_id
end

def selected_action
  selected_action_id && Action.fetch(selected_action_id)
end

def selected_content
  @selected_content ||= content_at_time_of_selected_action || db_content
end

def content_at_time_of_selected_action
  last_change_on(:db_content, not_after: selected_action_id,
                              including_drafts: true)&.value
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

private

def new_content_action_id
  return unless @current_action && current_action_changes_content?

  @current_action.id
end

def current_action_changes_content?
  new_card? || @current_action.new_content? || db_content_is_changing?
end

def action_from_id action_id
  return unless action_id.is_a?(Integer) || action_id =~ /^\d+$/
  # if not an integer, action_id is probably a mod (e.g. if you request
  # files/:logo/standard.png)

  action_if_on_self Action.fetch(action_id)
end

def action_if_on_self action
  return unless action.is_a? Action

  action if action.card_id == id
end
