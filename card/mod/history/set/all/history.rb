ACTS_PER_PAGE = 3 # Card.config.acts_per_page

# track history (acts, actions, changes) on this card
def history?
  true
end

# all acts with actions on self and on cards included in self (ie, acts shown in history)
def historical_acts
  @historical_acts ||=
    Act.find_all_with_actions_on (included_card_ids << id), with_drafts: true
end

format :html do
  view :history, cache: :never do
    frame do
      voo.show :toolbar
      class_up "d0-card-body",  "history-slot"
      acts_layout card.historical_acts, :relative, ACTS_PER_PAGE, :show
    end
  end

  def revert_actions_link act, link_text,
                          revert_to: :this, slot_selector: nil, html_args: {}
    return unless card.ok? :update
    html_args.merge! remote: true, method: :post, rel: "nofollow",
                     path: { action: :update, view: :open, look_in_trash: true,
                             revert_actions: act.actions.map(&:id),
                             revert_to: revert_to }

    html_args[:path]["data-slot-selector"] = slot_selector if slot_selector
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

  view :draft_legend do
    "#{action_icon(:draft)} unsaved draft"
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

def first_change? # = update or delete
  @current_action.action_type != :create && @current_action.card.actions.size == 2 &&
    create_action.card_changes.empty?
end

def changed_fields
  Card::Change::TRACKED_FIELDS & (changed_attribute_names_to_save | saved_changes.keys)
end

def current_historical_act_number
  @current_historical_act_number ||=
    if historical_acts.first.actions.last.draft
      historical_acts.size - 1
    else
      historical_acts.size
    end
end

def included_card_ids
  @included_card_ids ||=
    Card::Reference.select(:referee_id).where(
      ref_type: "I", referer_id: id
    ).pluck("referee_id").compact.uniq
end

def diff_args
  { diff_format: :text }
end

def has_edits?
  Card::Act.where(actor_id: id).where("card_id IS NOT NULL").present?
end
