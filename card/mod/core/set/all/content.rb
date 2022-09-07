event :set_content, :store, on: :save do
  self.content = prepare_db_content
  @selected_action_id = @selected_content = nil
  clear_drafts
end

event :save_draft, :store, on: :update, when: :draft? do
  save_content_draft content
  abort :success
end

event :set_default_content, :prepare_to_validate,
      on: :create, when: :use_default_content? do
  self.db_content = default_content
end

def draft?
  Env.params["draft"] == "true"
end

def clean_html?
  true
end

# TODO: let default_content in card_accessor override template
def default_content
  template&.db_content
end

def use_default_content?
  !db_content_changed? && default_content.present?
end

def unfilled?
  blank_content? && blank_comment? && !subcards?
end

def blank_comment?
  comment.blank? || comment.strip.blank?
end

def prepare_db_content
  cont = standard_db_content || "" # necessary?

  # TODO: move this html-specific code somewhere more appropriate
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
