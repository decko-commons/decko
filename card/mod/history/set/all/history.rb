ACTS_PER_PAGE = Card.config.acts_per_page

def history?
  true
end

# must be called on all actions and before :set_name, :process_subcards and
# :validate_delete_children

def actionable?
  history?
end

event :assign_action, :initialize, when: proc { |c| c.actionable? } do
  @current_act = director.need_act
  @current_action = Card::Action.create(
    card_act_id: @current_act.id,
    action_type: @action,
    draft: (Env.params["draft"] == "true")
  )
  if @supercard && @supercard != self
    @current_action.super_action = @supercard.current_action
  end
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

def first_change? # = update or delete
  @current_action.action_type != :create && @current_action.card.actions.size == 2 &&
    create_action.card_changes.empty?
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

def changed_fields
  Card::Change::TRACKED_FIELDS & (changed_attribute_names_to_save | saved_changes.keys)
end

def finalize_action?
  actionable? && current_action
end

event :finalize_act,
      after: :finalize_action,
      when: proc { |c|  c.act_card? } do
  @current_act.update_attributes! card_id: id
end

event :remove_empty_act,
      :integrate_with_delay_final, when: :remove_empty_act? do
  #@current_act.delete
  #@current_act = nil
end

def remove_empty_act?
  act_card? && @current_act&.actions&.reload&.empty?
end


def act_card?
  self == Card::ActManager.act_card
end

event :rollback_actions,
      :prepare_to_validate, on: :update, when: :rollback_request? do
  revision = { subcards: {} }

  rollback_actions.each do |action|
    if action.card_id == id
      revision.merge!(revision(action))
    else
      revision[:subcards][action.card.name] = revision(action)
    end
  end
  Env.params["action_ids"] = nil
  update_attributes! revision
  clear_drafts
  abort :success
end

def rollback_actions
  actions =
    Env.params["revert_actions"].map do |a_id|
      Action.fetch(a_id) || nil
    end.compact
  actions.map! { |a| a.previous_action } if Env.params["revert_to"] == "previous"
  actions.compact
end

def rollback_request?
  history? && Env&.params["revert_actions"]&.class == Array
end

# all acts with actions on self and on cards that are descendants of self and
# included in self
def intrusive_family_acts args={}
  @intrusive_family_acts ||= begin
    Act.find_all_with_actions_on((included_descendant_card_ids << id), args)
  end
end

# all acts with actions on self and on cards included in self
def intrusive_acts args={ with_drafts: true }
  @intrusive_acts ||= begin
    Act.find_all_with_actions_on((included_card_ids << id), args)
  end
end

def current_rev_nr
  @current_rev_nr ||= begin
    if intrusive_acts.first.actions.last.draft
      @intrusive_acts.size - 1
    else
      @intrusive_acts.size
    end
  end
end

def included_card_ids
  @included_card_ids ||=
    Card::Reference.select(:referee_id).where(
      ref_type: "I", referer_id: id
    ).pluck("referee_id").compact.uniq
end

def descendant_card_ids parent_ids=[id]
  more_ids = Card.where("left_id IN (?)", parent_ids).pluck("id")
  more_ids += descendant_card_ids more_ids unless more_ids.empty?
  more_ids
end

def included_descendant_card_ids
  included_card_ids & descendant_card_ids
end

format :html do
  view :history, cache: :never do
    voo.show :toolbar
    class_up "d0-card-body",  "history-slot"
    frame do
      bs_layout container: true, fluid: true do
        html _optional_render_history_legend(with_drafts: true)
        row 12 do
          html _render_act_list acts: history_acts
        end
        row 12 do
          col act_paging
        end
      end
    end
  end

  view :history_legend do |args|
    bs_layout do
      row md: [12, 12], lg: [7, 5] do
        col action_legend(args[:with_drafts])
        col content_legend, class: "text-right"
      end
    end
  end

  def history_acts
    card.intrusive_acts.page(page_from_params).per(ACTS_PER_PAGE)
  end

  def act_paging
    intrusive_acts = card.intrusive_acts
                         .page(page_from_params).per(ACTS_PER_PAGE)
    wrap_with :span, class: "slotter" do
      paginate intrusive_acts, remote: true, theme: "twitter-bootstrap-4"
    end
  end

  def page_from_params
    params["page"] || 1
  end

  def action_legend with_drafts=true
    types = %i[create update delete]
    legend = types.map do |action_type|
      "#{action_icon(action_type)} #{action_type}d"
    end
    legend << "#{action_icon(:draft)} unsaved draft" if with_drafts
    "<small>Actions: #{legend.join ' | '}</small>"
  end

  def content_legend
    legend = [Card::Content::Diff.render_added_chunk("Additions"),
              Card::Content::Diff.render_deleted_chunk("Subtractions")]
    "<small>Content changes: #{legend.join ' | '}</small>"
  end

  view :content_changes do |args|
    action = args[:action]
    if args[:hide_diff]
      action.raw_view
    else
      action.content_diff(args[:diff_type])
    end
  end
end

def diff_args
  { diff_format: :text }
end

def has_edits?
  Card::Act.where(actor_id: id).where("card_id IS NOT NULL").present?
end
