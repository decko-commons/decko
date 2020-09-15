def content= value
  self.db_content = standardize_content(value)
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

def standardize_content value
  value.is_a?(Array) ? value.join("\n") : value
end

def structured_content
  structure && template.db_content
end

def refresh_content
  self.content = Card.find(id)&.db_content
end

format do
  ONE_LINE_CHARACTER_LIMIT = 60

  def chunk_list # override to customize by set
    :default
  end

  view :one_line_content do
    with_nest_mode :compact do
      one_line_content
    end
  end

  # DEPRECATED
  view :closed_content, :one_line_content

  view :raw_one_line_content do
    raw_one_line_content
  end

  view :label do
    card.label.to_s
  end

  view :smart_label, cache: :never, unknown: true do
    label_with_description render_label, label_description
  end

  def label_with_description label, description
    return label unless description

    "#{label} #{popover_link description}"
  end

  # TODO: move this into a nest once popovers are stub safe
  def label_description
    return unless (desc = card.field :description)

    desc.format.render_core
  end

  def raw_one_line_content
    cut_with_ellipsis render_raw
  end

  def one_line_content
    Card::Content.smart_truncate render_core
  end

  def cut_with_ellipsis text, limit=one_line_character_limit
    if text.size <= limit
      text
    else
      text[0..(limit - 3)] + "..."
    end
  end

  def one_line_character_limit
    voo.size || ONE_LINE_CHARACTER_LIMIT
  end
end

format :html do
  view :hidden_content_field, unknown: true, cache: :never do
    hidden_field :content, class: "d0-card-content"
  end
end

# seems like this should be moved to format so we can fall back on title
# rather than name. (In fact, name, title, AND label is a bit much.
# Trim to 2?)
def label
  name
end

def creator
  Card[creator_id]
end

def updater
  Card[updater_id]
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
  self.db_content = prepare_db_content
  @selected_action_id = @selected_content = nil
  clear_drafts
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

def prepare_db_content
  cont = standard_db_content || "" # necessary?
  clean_html? ? Card::Content.clean!(cont) : cont
end

def standard_db_content
  if structure
    # do not override db_content with content from structure
    db_content
  else
    standard_content
  end
end

def clean_html?
  true
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
