# action id of the cached upload
attr_accessor :action_id_of_cached_upload

def actionable?
  super || preliminary_upload?
end

event :upload_attachment, :prepare_to_validate,
      on: :save, when: proc { |c| c.preliminary_upload? } do
  save_original_filename  # save original filename as comment in action
  write_identifier        # set db_content
  # (needs original filename to determine extension)
  store_attachment!
  store_card_changes
  # finalize_action         # create Card::Change entry for db_content

  card_id = new_card? ? upload_cache_card.id : id
  @current_action.update_attributes! draft: true, card_id: card_id
  success << {
    target: (new_card? ? upload_cache_card : self),
    type: type_name,
    view: "preview_editor",
    rev_id: current_action.id
  }
  abort :success
end

event :assign_attachment_on_create, :initialize,
      after: :assign_action, on: :create,
      when: proc { |c| c.save_preliminary_upload? } do
  return unless  (action = Card::Action.fetch(@action_id_of_cached_upload))
  upload_cache_card.selected_action_id = action.id
  upload_cache_card.select_file_revision
  assign_attachment upload_cache_card.attachment.file, action.comment
end

event :assign_attachment_on_update, :initialize,
      after: :assign_action, on: :update,
      when:  proc { |c| c.save_preliminary_upload? } do
  return unless (action = Card::Action.fetch(@action_id_of_cached_upload))
  uploaded_file = with_selected_action_id(action.id) { attachment.file }
  assign_attachment uploaded_file, action.comment
end

def assign_attachment file, original_filename
  send "#{attachment_name}=", file
  write_identifier
  @current_action.update_attributes! comment: original_filename if @current_action
end

event :delete_cached_upload_file_on_create, :integrate,
      on: :create, when: proc { |c| c.save_preliminary_upload? } do
  return unless (action = Card::Action.fetch(@action_id_of_cached_upload))
  upload_cache_card.delete_files_for_action action
  action.delete
end

# at some point uploaded files of canceled file card creation
# should be deleted. We do this when ever an new file is created.
event :clear_draft_files, :integrate_with_delay,
      on: :create do
  Card.delete_tmp_files_of_cached_uploads
end

event :delete_cached_upload_file_on_update, :integrate,
      on: :update, when: proc { |c| c.save_preliminary_upload? } do
  return unless  (action = Card::Action.fetch(@action_id_of_cached_upload))
  delete_files_for_action action
  action.delete
end

# used for uploads for new cards until the new card is created
def upload_cache_card
  cache_card_codename = "new_#{attachment_name}"
  @upload_cache_card ||= Card::Codename.card(cache_card_codename) { Card[:new_file] }
end

def preliminary_upload?
  Card::Env && Card::Env.params[:attachment_upload]
end

def save_preliminary_upload?
  @action_id_of_cached_upload.present?
end

# place for files if card doesn't have an id yet
def tmp_upload_dir _action_id=nil
  "#{files_base_dir}/#{upload_cache_card.id}"
end
