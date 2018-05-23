format :html do
  view :action_summary do
    action_content action_from_context, :summary
  end

  view :action_expanded do
    action_content action_from_context, :expanded
  end

  def action_from_context
    if (action_id = voo.action_id || params[:action_id])
      Action.fetch action_id
    else
      card.last_action
    end
  end

  def action_content action, view_type
    return "" unless action.present?
    wrap do
      [action_content_toggle(action, view_type),
       content_diff(action, view_type)]
    end
  end

  def content_diff action, view_type
    diff = action.new_content? && content_changes(action, view_type)
    return "<i>empty</i>" unless diff.present?
    diff
  end

  def action_content_toggle action, view_type
    return unless show_action_content_toggle?(action, view_type)
    toggle_action_content_link action, view_type
  end

  def show_action_content_toggle? action, view_type
    view_type == :expanded || action.summary_diff_omits_content?
  end

  def toggle_action_content_link action, view_type
    other_view_type = view_type == :expanded ? :summary : :expanded
    link_to_view "action_#{other_view_type}",
                 icon_tag(action_arrow_dir(view_type)),
                 class: "slotter revision-#{action.card_act_id} float-right",
                 path: { action_id: action.id, look_in_trash: true }
  end

  def action_arrow_dir view_type
    view_type == :expanded ? :triangle_left : :triangle_right
  end
end
