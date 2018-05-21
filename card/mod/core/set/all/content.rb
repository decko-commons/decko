::Card.error_codes[:conflict] = [:conflict, 409]

def content= value
  self.db_content = value
end

def content
  structured_content || standard_content
end
alias raw_content content #DEPRECATED!

def content?
  content.present?
end

def standard_content
  db_content || (new_card? && template.db_content)
end

def structured_content
  structure && template.db_content
end

def context_card
  @context_card || self
end

def with_context context_card
  old_context = @context_card
  @context_card = context_card if context_card
  yield
ensure
  @context_card = old_context
end

format do
  def chunk_list # override to customize by set
    :default
  end

  def context_card
    card.context_card
  end

  def with_context context_card
    card.with_context context_card do
      yield
    end
  end

  def contextual_content context_card, options={}
    view = options.delete(:view) || :core
    with_context(context_card) { render! view, options }
  end
end

format :html do
  view :hidden_content_field, tags: :unknown_ok, cache: :never do
    hidden_field :content, class: "d0-card-content"
  end
end

def label
  name
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

def save_content_draft _content
  clear_drafts
end

def clear_drafts
  drafts.created_by(Card::Auth.current_id).each(&:delete)
end

def last_draft_content
  drafts.last.card_changes.last.value
end

event :set_content, :store, on: :save do
  self.db_content = prepare_content
  @selected_action_id = @selected_content = nil
  clear_drafts
  reset_patterns_if_rule true
end

event :save_draft, :store, on: :update, when: :draft? do
  save_content_draft content
  abort :success
end

event :set_default_content,
      :prepare_to_validate,
      on: :create, when: :use_default_content? do
  self.db_content = template.db_content
end

def draft?
  Env.params["draft"] == "true"
end

def prepare_content
  cont = standard_content || "" # necessary?
  clean_html? ? Card::Content.clean!(cont) : cont
end

def use_default_content?
  !db_content_changed? && template && template.db_content.present?
end

def unfilled?
  blank_content? && blank_comment? && !subcards?
end

def blank_content?
  content.blank? || content.strip.blank?
end

def blank_comment?
  comment.blank? || comment.strip.blank?
end
