# -*- encoding : utf-8 -*-

def all_action_ids
  Card::Action.where(card_id: id).pluck :id
end

def old_actions
  actions.where("id != ?", last_action_id)
end

def create_action
  @create_action ||= actions.first
end

def nth_action index
  index = index.to_i
  return unless id && index.positive?

  Action.where("draft is not true AND card_id = #{id}")
        .order(:id).limit(1).offset(index - 1).first
end

format :html do
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
    css_class = "revision-#{action.card_act_id} float-end"
    link_to_view "action_#{other_view_type}",
                 icon_tag(action_arrow_dir(view_type)),
                 class: css_class,
                 path: { action_id: action.id, look_in_trash: true }
  end

  def action_arrow_dir view_type
    view_type == :expanded ? :collapse : :expand
  end

  def revert_actions_link link_text, path_args, html_args={}
    return unless card.ok? :update

    path_args.reverse_merge! action: :update, look_in_trash: true, assign: true,
                             card: { skip: :validate_renaming }
    html_args.reverse_merge! remote: true, method: :post, rel: "nofollow", path: path_args
    add_class html_args, "slotter"
    link_to link_text, html_args
  end

  def action_legend
    types = %i[create update delete]
    legend = types.map do |action_type|
      "#{action_icon(action_type)} #{action_type}d"
    end
    legend << _render_draft_legend if voo.show?(:draft_legend)
    "<small>Actions: #{legend.join ' | '}</small>"
  end

  def content_legend
    legend = [Card::Content::Diff.render_added_chunk("Additions"),
              Card::Content::Diff.render_deleted_chunk("Subtractions")]
    "<small>Content changes: #{legend.join ' | '}</small>"
  end

  def content_changes action, diff_type, hide_diff=false
    if hide_diff
      action.raw_view
    else
      action.content_diff diff_type
    end
  end
end
